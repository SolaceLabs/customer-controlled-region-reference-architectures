package common

import (
	"archive/zip"
	"bufio"
	"fmt"
	"io"
	"net/http"
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

func CopyTerraformState(t *testing.T, sourcePath string, targetPath string) {
	sourceState := fmt.Sprintf("%s/terraform.tfstate", sourcePath)

	source, err := os.Open(sourceState)
	if err != nil {
		t.Fatal(err)
	}
	defer source.Close()

	targetState := fmt.Sprintf("%s/terraform.tfstate", targetPath)

	destination, err := os.Create(targetState)
	if err != nil {
		t.Fatal(err)
	}
	defer destination.Close()

	_, err = io.Copy(destination, source)
	if err != nil {
		t.Fatal(err)
	}
}

func CopyTerraform(t *testing.T, sourcePath string) string {
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

	err := os.MkdirAll(targetPath, os.ModePerm)
	if err != nil {
		t.Fatal(err)
	}

	logger.Log(t, fmt.Sprintf("Copying terraform project from %s to %s", sourcePath, targetPath))

	err = files.CopyFolderContentsWithFilter(sourcePath, targetPath, filter)
	if err != nil {
		t.Fatal(err)
	}

	return targetPath
}

func downloadFile(url string, path string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	zipFile := fmt.Sprintf("%s/file.zip", path)

	out, err := os.Create(zipFile)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	if err != nil {
		return err
	}

	reader, err := zip.OpenReader(zipFile)
	if err != nil {
		return err
	}
	defer reader.Close()

	for _, f := range reader.File {
		err := unzipFile(f, path)
		if err != nil {
			return err
		}
	}
	return nil
}

func unzipFile(f *zip.File, destination string) error {
	filePath := filepath.Join(destination, f.Name)
	if !strings.HasPrefix(filePath, filepath.Clean(destination)+string(os.PathSeparator)) {
		return fmt.Errorf("invalid file path: %s", filePath)
	}

	if f.FileInfo().IsDir() {
		if err := os.MkdirAll(filePath, os.ModePerm); err != nil {
			return err
		}
		return nil
	}

	if err := os.MkdirAll(filepath.Dir(filePath), os.ModePerm); err != nil {
		return err
	}

	destinationFile, err := os.OpenFile(filePath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
	if err != nil {
		return err
	}
	defer destinationFile.Close()

	zippedFile, err := f.Open()
	if err != nil {
		return err
	}
	defer zippedFile.Close()

	if _, err := io.Copy(destinationFile, zippedFile); err != nil {
		return err
	}
	return nil
}

func CopyTerraformFromRepository(t *testing.T, kubernetesFlavour string, releaseVersion string) string {
	url := fmt.Sprintf("https://github.com/SolaceLabs/customer-controlled-region-reference-architectures/releases/"+
		"download/%s/customer-controlled-region-reference-architectures-%s-%s.zip", releaseVersion, kubernetesFlavour, releaseVersion)

	targetPath := fmt.Sprintf("./terraform/%s", t.Name())
	os.MkdirAll(targetPath, os.ModePerm)

	logger.Log(t, fmt.Sprintf("Copying terraform project for %s version %s from Github to %s", kubernetesFlavour, releaseVersion, targetPath))

	err := downloadFile(url, targetPath)
	if err != nil {
		t.Fatal(err)
	}

	return fmt.Sprintf("%s/%s/terraform", targetPath, kubernetesFlavour)
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
