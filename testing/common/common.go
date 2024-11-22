package common

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/ssh"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
)

const (
	Red   = "\033[31m"
	Green = "\033[32m"
	Blue  = "\033[34m"
	Cyan  = "\033[36m"
	Reset = "\033[0m"
)

func CopyTerraform(t *testing.T, sourcePath string) (string, error) {
	filter := func(path string) bool {
		if files.PathIsTerraformVersionFile(path) || files.PathIsTerraformLockFile(path) {
			return true
		}
		if files.PathContainsHiddenFileOrFolder(path) || files.PathContainsTerraformStateOrVars(path) {
			return false
		}
		return true
	}

	base := filepath.Base(sourcePath)
	targetPath := fmt.Sprintf("./terraform/%s/%s", t.Name(), base)

	os.MkdirAll(targetPath, os.ModePerm)

	logger.Log(t, fmt.Sprintf("Copying terraform project from %s to %s", sourcePath, targetPath))
	return targetPath, files.CopyFolderContentsWithFilter(sourcePath, targetPath, filter)
}

func WriteKubeconfigToTempFile(kubeconfig string) string {
	kubeconfigFile, _ := os.CreateTemp(os.TempDir(), "kubeconfig")

	w := bufio.NewWriter(kubeconfigFile)
	w.WriteString(kubeconfig)
	w.Flush()

	kubeconfigFile.Close()

	return kubeconfigFile.Name()
}

func TestHighAvailableServiceClass(t *testing.T, kubeconfigPath string, serviceClass string, storageClass string, serviceCount int) {
	TestServiceClassWithValues(t, kubeconfigPath, serviceClass, storageClass, []string{}, serviceCount, true)
}

func TestStandaloneServiceClass(t *testing.T, kubeconfigPath string, serviceClass string, storageClass string, serviceCount int) {
	TestServiceClassWithValues(t, kubeconfigPath, serviceClass, storageClass, []string{}, serviceCount, false)
}

func TestServiceClassWithValues(t *testing.T, kubeconfigPath string, serviceClass string, storageClass string, valuesFiles []string, serviceCount int, highlyAvailable bool) {
	namespaceName := fmt.Sprintf("%s-%s", serviceClass, strings.ToLower(random.UniqueId()))

	logger.Log(t, fmt.Sprintf("%s>>>>>>>>>> START, serviceClass: %s storageClass: %s highlyAvailable: %t count: %d, namespace: %s%s",
		Blue, serviceClass, storageClass, highlyAvailable, serviceCount, namespaceName, Reset))

	options := k8s.NewKubectlOptions("", kubeconfigPath, namespaceName)

	defer k8s.DeleteNamespace(t, options, namespaceName)
	k8s.CreateNamespace(t, options, namespaceName)

	helmChartPath, err := filepath.Abs("../charts/test-service")
	require.NoError(t, err)

	helmOptions := &helm.Options{
		KubectlOptions: options,
		SetValues: map[string]string{
			"serviceClass":         serviceClass,
			"storage.storageClass": storageClass,
			"highlyAvailable":      strconv.FormatBool(highlyAvailable),
		},
		ValuesFiles: valuesFiles,
	}

	for i := 0; i < serviceCount; i++ {
		releaseName := fmt.Sprintf("%s-%s", serviceClass, strings.ToLower(random.UniqueId()))

		defer helm.Delete(t, helmOptions, releaseName, true)
		err := helm.InstallE(t, helmOptions, helmChartPath, releaseName)
		if err != nil {
			printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, fmt.Sprintf("helm install failed, release: %s", releaseName))
			t.Fatal(err)
		}

		printTestProgress(t, serviceClass, storageClass, highlyAvailable, namespaceName, fmt.Sprintf("helm chart installed, release: %s", releaseName))

		err = k8s.WaitUntilPodAvailableE(t, options, fmt.Sprintf("%s-test-service-primary-0", releaseName), 30, 30*time.Second)
		if err != nil {
			printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, "primary pod not available")
			t.Fatal(err)
		}

		if highlyAvailable {
			err = k8s.WaitUntilPodAvailableE(t, options, fmt.Sprintf("%s-test-service-backup-0", releaseName), 30, 30*time.Second)
			if err != nil {
				printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, "backup pod not available")
				t.Fatal(err)
			}

			err = k8s.WaitUntilPodAvailableE(t, options, fmt.Sprintf("%s-test-service-monitoring-0", releaseName), 30, 30*time.Second)
			if err != nil {
				printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, "monitoring pod not available")
				t.Fatal(err)
			}
		}

		printTestProgress(t, serviceClass, storageClass, highlyAvailable, namespaceName, fmt.Sprintf("pods available, release: %s", releaseName))

		serviceName := fmt.Sprintf("%s-test-service", releaseName)

		k8s.WaitUntilServiceAvailable(t, options, serviceName, 30, 30*time.Second)
		service, err := k8s.GetServiceE(t, options, serviceName)
		if err != nil {
			printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, "service not available")
			t.Fatal(err)
		}

		printTestProgress(t, serviceClass, storageClass, highlyAvailable, namespaceName, fmt.Sprintf("service available, release: %s", releaseName))

		url := fmt.Sprintf("http://%s", k8s.GetServiceEndpoint(t, options, service, 943))
		err = http_helper.HttpGetWithRetryE(t, url, nil, 200, "Test Service", 30, 30*time.Second)
		if err != nil {
			printTestFailure(t, serviceClass, storageClass, highlyAvailable, namespaceName, "cannot connect to load balancer")
			t.Fatal(err)
		}

		logger.Log(t, fmt.Sprintf("%s<<<<<<<<<< PASSED, serviceClass: %s storageClass: %s highlyAvailable: %t namespace: %s%s",
			Green, serviceClass, storageClass, highlyAvailable, namespaceName, Reset))
	}
}

func printTestProgress(t *testing.T, serviceClass string, storageClass string, highlyAvailable bool, namespaceName string, message string) {
	logger.Log(t, fmt.Sprintf("%s========== %s, serviceClass: %s storageClass: %s highlyAvailable: %t namespace: %s%s",
		Cyan, message, serviceClass, storageClass, highlyAvailable, namespaceName, Reset))
}

func printTestFailure(t *testing.T, serviceClass string, storageClass string, highlyAvailable bool, namespaceName string, reason string) {
	logger.Log(t, fmt.Sprintf("%s<<<<<<<<<< FAILED %s, serviceClass: %s storageClass: %s highlyAvailable: %t namespace: %s%s",
		Red, reason, serviceClass, storageClass, highlyAvailable, namespaceName, Reset))
}

func PrintTestComplete(t *testing.T) {
	logger.Log(t, fmt.Sprintf("%s<<<<<<<<<< TEST COMPLETE%s", Green, Reset))
}

func TestSshToBastionHost(t *testing.T, bastionPublicIp string, bastionUsername string, bastionPrivateKey string) {
	keyPair := ssh.KeyPair{PrivateKey: bastionPrivateKey}

	publicHost := ssh.Host{
		Hostname:    bastionPublicIp,
		SshKeyPair:  &keyPair,
		SshUserName: bastionUsername,
	}

	ssh.CheckSshConnectionWithRetry(t, publicHost, 30, 5*time.Second)
}

func GenerateTags(clusterName string) map[string]string {
	return map[string]string{
		"deployment-type": "datacenter",
		"deployment-env":  "development",
		"home-cloud-id":   "testing",
		"datacenter-type": "solace-dedicated",
		"datacenter-id":   clusterName,
		"organization-id": "testing",
	}
}
