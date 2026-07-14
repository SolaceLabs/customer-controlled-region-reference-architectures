package common

import (
	"bufio"
	"fmt"
	"math/rand"
	"net"
	"os"
	"os/exec"
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

func CopyTerraform(t *testing.T, sourcePath string, suffix string) (string, error) {
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
	targetPath := fmt.Sprintf("./terraform/%s-%s/%s", t.Name(), suffix, base)

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

const (
	// A small, dependency-free image (pullable via the cluster's Cloud NAT) that
	// can act as both an HTTP server (`netexec`) and a TCP connectivity prober
	// (`connect`).
	netpolProbeImage = "registry.k8s.io/e2e-test-images/agnhost:2.47"
	netpolServerPort = 8080
	netpolRetries    = 12
	netpolInterval   = 5 * time.Second
)

// TestNetworkPolicyEnforcement verifies that Kubernetes NetworkPolicy is
// actually enforced by the cluster's network plugin (for GKE this is Dataplane
// V2 / Cilium, enabled via datapath_provider = "ADVANCED_DATAPATH").
//
// It deploys a server pod and a client pod, then:
//  1. confirms the client can reach the server with no policy in place,
//  2. applies a default-deny ingress policy on the server and confirms the
//     traffic is now blocked, and
//  3. applies an allow policy for the client and confirms connectivity is
//     restored.
//
// Step 2 is the crux: a cluster that does not enforce NetworkPolicy would still
// allow the traffic and fail this test.
func TestNetworkPolicyEnforcement(t *testing.T, kubeconfigPath string) {
	namespaceName := fmt.Sprintf("netpol-%s", strings.ToLower(random.UniqueId()))

	logger.Log(t, fmt.Sprintf("%s>>>>>>>>>> START, network policy enforcement, namespace: %s%s", Blue, namespaceName, Reset))

	options := k8s.NewKubectlOptions("", kubeconfigPath, namespaceName)

	defer k8s.DeleteNamespace(t, options, namespaceName)
	k8s.CreateNamespace(t, options, namespaceName)

	serverManifest := fmt.Sprintf(`
apiVersion: v1
kind: Pod
metadata:
  name: netpol-server
  labels:
    app: netpol-server
spec:
  containers:
  - name: agnhost
    image: %s
    args: ["netexec", "--http-port=%d"]
    ports:
    - containerPort: %d
`, netpolProbeImage, netpolServerPort, netpolServerPort)

	clientManifest := fmt.Sprintf(`
apiVersion: v1
kind: Pod
metadata:
  name: netpol-client
  labels:
    app: netpol-client
spec:
  containers:
  - name: agnhost
    image: %s
    args: ["pause"]
`, netpolProbeImage)

	k8s.KubectlApplyFromString(t, options, serverManifest)
	k8s.KubectlApplyFromString(t, options, clientManifest)

	k8s.WaitUntilPodAvailable(t, options, "netpol-server", 30, netpolInterval)
	k8s.WaitUntilPodAvailable(t, options, "netpol-client", 30, netpolInterval)

	serverIp, err := k8s.RunKubectlAndGetOutputE(t, options, "get", "pod", "netpol-server", "-o", "jsonpath={.status.podIP}")
	require.NoError(t, err)
	require.NotEmpty(t, serverIp, "server pod IP should be assigned")

	target := fmt.Sprintf("%s:%d", serverIp, netpolServerPort)

	// 1) Baseline: with no policy, the client must reach the server.
	waitForNetworkReachability(t, options, target, true,
		"baseline connectivity established (no policy)")

	// 2) Default-deny ingress on the server: traffic must now be blocked.
	denyPolicy := `
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpol-deny-server-ingress
spec:
  podSelector:
    matchLabels:
      app: netpol-server
  policyTypes:
  - Ingress
`
	k8s.KubectlApplyFromString(t, options, denyPolicy)

	waitForNetworkReachability(t, options, target, false,
		"traffic blocked after default-deny ingress policy")

	// 3) Allow ingress from the client: connectivity must be restored. This
	// distinguishes real policy enforcement from the pod simply being down.
	allowPolicy := fmt.Sprintf(`
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpol-allow-client-ingress
spec:
  podSelector:
    matchLabels:
      app: netpol-server
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: netpol-client
    ports:
    - protocol: TCP
      port: %d
`, netpolServerPort)
	k8s.KubectlApplyFromString(t, options, allowPolicy)

	waitForNetworkReachability(t, options, target, true,
		"traffic restored after allow policy for client")

	logger.Log(t, fmt.Sprintf("%s<<<<<<<<<< PASSED, network policy enforcement, namespace: %s%s", Green, namespaceName, Reset))
}

// networkProbe attempts a TCP connection from the client pod to target
// (host:port) and returns nil if it succeeds, an error if it is refused or
// times out (i.e. blocked).
func networkProbe(t *testing.T, options *k8s.KubectlOptions, target string) error {
	_, err := k8s.RunKubectlAndGetOutputE(t, options, "exec", "netpol-client", "--",
		"/agnhost", "connect", target, "--timeout=5s")
	return err
}

// waitForNetworkReachability polls the client->server probe until it matches
// wantReachable (allowing time for the policy to be programmed), failing the
// test if the desired state is not reached within the retry budget.
func waitForNetworkReachability(t *testing.T, options *k8s.KubectlOptions, target string, wantReachable bool, description string) {
	for i := 0; i < netpolRetries; i++ {
		reachable := networkProbe(t, options, target) == nil
		if reachable == wantReachable {
			logger.Log(t, fmt.Sprintf("%s========== %s%s", Cyan, description, Reset))
			return
		}
		time.Sleep(netpolInterval)
	}
	t.Fatalf("network policy not enforced as expected: %q (wanted reachable=%v to %s)", description, wantReachable, target)
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

// StartSocksProxyThroughBastion opens an SSH SOCKS5 proxy (`ssh -N -D`) to the
// bastion host and returns the socks5 URL to use for reaching the (private)
// Kubernetes API, plus a cleanup function that tears the proxy down. It blocks
// until the local proxy port is accepting connections.
//
// This lets the test reach a private-endpoint cluster through the bastion,
// removing any dependency on the test runner's egress IP being allow-listed on
// the Kubernetes API.
func StartSocksProxyThroughBastion(t *testing.T, bastionIp string, bastionUsername string, bastionPrivateKey string) (string, func()) {
	keyFile, err := os.CreateTemp(os.TempDir(), "bastion-key")
	require.NoError(t, err)
	_, err = keyFile.WriteString(bastionPrivateKey)
	require.NoError(t, err)
	require.NoError(t, keyFile.Close())
	require.NoError(t, os.Chmod(keyFile.Name(), 0600))

	// Ask the OS for a free local port, then release it for ssh to bind. Each
	// (parallel) test gets its own port this way.
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	port := listener.Addr().(*net.TCPAddr).Port
	require.NoError(t, listener.Close())

	localAddr := fmt.Sprintf("127.0.0.1:%d", port)

	cmd := exec.Command("ssh",
		"-i", keyFile.Name(),
		"-N",
		"-D", localAddr,
		"-o", "StrictHostKeyChecking=no",
		"-o", "UserKnownHostsFile=/dev/null",
		"-o", "ExitOnForwardFailure=yes",
		"-o", "ServerAliveInterval=30",
		fmt.Sprintf("%s@%s", bastionUsername, bastionIp),
	)

	logger.Log(t, fmt.Sprintf("Starting SSH SOCKS5 proxy to bastion %s on %s", bastionIp, localAddr))
	require.NoError(t, cmd.Start())

	cleanup := func() {
		if cmd.Process != nil {
			cmd.Process.Kill()
			cmd.Wait()
		}
		os.Remove(keyFile.Name())
	}

	// Wait until the proxy port accepts connections. The bastion may still be
	// booting/accepting SSH, so retry generously.
	ready := false
	for i := 0; i < 30; i++ {
		conn, dialErr := net.DialTimeout("tcp", localAddr, 5*time.Second)
		if dialErr == nil {
			conn.Close()
			ready = true
			break
		}
		time.Sleep(5 * time.Second)
	}
	if !ready {
		cleanup()
		t.Fatalf("SSH SOCKS5 proxy to bastion %s did not become ready", bastionIp)
	}

	logger.Log(t, fmt.Sprintf("%sSSH SOCKS5 proxy ready on %s%s", Green, localAddr, Reset))
	return fmt.Sprintf("socks5://%s", localAddr), cleanup
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

const charset = "abcdefghijklmnopqrstuvwxyz0123456789"

var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))

func stringWithCharset(length int, charset string) string {
	b := make([]byte, length)
	for i := range b {
		b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

func UniqueId(length int) string {
	return stringWithCharset(length, charset)
}
