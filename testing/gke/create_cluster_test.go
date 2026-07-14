package gke

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Prerequisite, set the GCP project with: export TF_VAR_project=<project>

const KubernetesVersion = "1.29"

func destroyGke(t *testing.T, options *terraform.Options, networkName string) {
	if _, err := terraform.DestroyE(t, options); err == nil {
		return
	}
	deleteNetworkFirewalls(t, networkName)
	terraform.Destroy(t, options)
}

func deleteNetworkFirewalls(t *testing.T, networkName string) {
	project := os.Getenv("TF_VAR_project")
	out, err := exec.Command("gcloud", "compute", "firewall-rules", "list",
		"--project", project,
		"--filter", fmt.Sprintf("network~%s", networkName),
		"--format", "value(name)").Output()
	if err != nil {
		t.Logf("could not list firewall rules for network %s: %v", networkName, err)
		return
	}
	for _, name := range strings.Fields(string(out)) {
		t.Logf("deleting orphaned firewall rule %s on network %s", name, networkName)
		if e := exec.Command("gcloud", "compute", "firewall-rules", "delete", name, "--project", project, "-q").Run(); e != nil {
			t.Logf("failed to delete firewall rule %s: %v", name, e)
		}
	}
}

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	serviceClassTests := []struct {
		name            string
		serviceClass    string
		highlyAvailable bool
		serviceCount    int
	}{
		{"prod1k-ha", "prod1k", true, 1},
		{"prod1k-standalone", "prod1k", false, 2},
		{"prod10k-ha", "prod10k", true, 1},
		{"prod10k-standalone", "prod10k", false, 2},
		{"prod100k-standalone", "prod100k", false, 1},
	}

	// Validate the service classes concurrently rather than one at a time. The
	// enclosing t.Run blocks until every parallel subtest completes, so it
	// returns before the caller tears the cluster down. Each subtest uses its
	// own namespace/releases (see common.TestServiceClassWithValues), so they
	// are safe to run in parallel against the same cluster.
	t.Run("validate", func(t *testing.T) {
		for _, tc := range serviceClassTests {
			tc := tc // capture range variable (Go 1.21)
			t.Run(tc.name, func(t *testing.T) {
				t.Parallel()
				if tc.highlyAvailable {
					common.TestHighAvailableServiceClass(t, kubeconfigPath, tc.serviceClass, "ssd", tc.serviceCount)
				} else {
					common.TestStandaloneServiceClass(t, kubeconfigPath, tc.serviceClass, "ssd", tc.serviceCount)
				}
			})
		}

		t.Run("network-policy", func(t *testing.T) {
			t.Parallel()
			common.TestNetworkPolicyEnforcement(t, kubeconfigPath)
		})
	})

	common.PrintTestComplete(t)
}

func TestTerraformGkeClusterComplete(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	clusterSuffix := os.Getenv("CLUSTER_SUFFIX")
	if clusterSuffix == "" {
		clusterSuffix = common.UniqueId(8) // 8 so the cluster name is 27 characters
	}

	region := "europe-west1"
	clusterName := fmt.Sprintf("terratest-complete-%s", clusterSuffix)

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites", clusterSuffix)
	prereqOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: prereqPath,
		NoColor:      true,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, prereqOptions)
	}
	terraform.InitAndApply(t, prereqOptions)

	bastionPublicKey := terraform.Output(t, prereqOptions, "bastion_ssh_public_key")

	underTestPath, _ := common.CopyTerraform(t, "../../gke/terraform", clusterSuffix)
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                    clusterName,
			"region":                          region,
			"kubernetes_version":              KubernetesVersion,
			"network_cidr_range":              "10.10.0.0/24",
			"secondary_cidr_range_pods":       "10.11.0.0/16",
			"secondary_cidr_range_services":   "10.12.0.0/16",
			"master_ipv4_cidr_block":          "10.100.0.0/28",
			"bastion_ssh_authorized_networks": []string{"0.0.0.0/0"},
			"bastion_ssh_public_key":          bastionPublicKey,
			// Use a private API endpoint and reach it through the bastion (see
			// the SOCKS proxy below), so the test does not depend on the runner's
			// egress IP being allow-listed. The cluster module already adds the
			// network CIDR to the master authorized networks for the bastion.
			"kubernetes_api_public_access":       false,
			"kubernetes_api_authorized_networks": []string{},
			"common_labels":                      common.GenerateTags(clusterName),
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer destroyGke(t, underTestOptions, clusterName+"-network")
	}
	terraform.InitAndApply(t, underTestOptions)

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")

	common.TestSshToBastionHost(t, bastionPublicIp, "ubuntu", bastionPrivateKey)

	// Tunnel Kubernetes API traffic through the bastion for the rest of the test.
	proxyUrl, stopProxy := common.StartSocksProxyThroughBastion(t, bastionPublicIp, "ubuntu", bastionPrivateKey)
	defer stopProxy()

	storageClassPath, _ := filepath.Abs("../../gke/kubernetes/storage-class.yaml")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":       clusterName,
			"region":             region,
			"storage_class_path": storageClassPath,
			"proxy_url":          proxyUrl,
		},
		Upgrade: true,
	})

	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}

func TestTerraformGkeClusterMessagingCidr(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	clusterSuffix := os.Getenv("CLUSTER_SUFFIX")
	if clusterSuffix == "" {
		clusterSuffix = common.UniqueId(15) // 15 so the cluster name is 30 characters
	}

	region := "europe-west3"
	clusterName := fmt.Sprintf("terratest-cidr-%s", clusterSuffix)

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites", clusterSuffix)
	prereqOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: prereqPath,
		NoColor:      true,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, prereqOptions)
	}
	terraform.InitAndApply(t, prereqOptions)

	localCidr := []string{terraform.Output(t, prereqOptions, "local_cidr")}

	underTestPath, _ := common.CopyTerraform(t, "../../gke/terraform", clusterSuffix)
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                        clusterName,
			"region":                              region,
			"kubernetes_version":                  KubernetesVersion,
			"network_cidr_range":                  "10.10.1.0/24",
			"secondary_cidr_range_pods":           "172.25.0.0/16",
			"secondary_cidr_range_services":       "172.26.0.0/16",
			"secondary_cidr_range_messaging_pods": "10.10.2.0/24",
			"master_ipv4_cidr_block":              "10.100.0.0/28",
			"max_pods_per_node_system":            110,
			"create_bastion":                      false,
			"kubernetes_api_public_access":        true,
			"kubernetes_api_authorized_networks":  localCidr,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer destroyGke(t, underTestOptions, clusterName+"-network")
	}
	terraform.InitAndApply(t, underTestOptions)

	storageClassPath, _ := filepath.Abs("../../gke/kubernetes/storage-class.yaml")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":       clusterName,
			"region":             region,
			"storage_class_path": storageClassPath,
		},
		Upgrade: true,
	})

	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}

func TestTerraformGkeClusterExternalNetwork(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	clusterSuffix := os.Getenv("CLUSTER_SUFFIX")
	if clusterSuffix == "" {
		clusterSuffix = common.UniqueId(12) // 12 so the cluster name is 30 characters
	}

	region := "us-east1"
	clusterName := fmt.Sprintf("terratest-network-%s", clusterSuffix)

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites", clusterSuffix)
	prereqOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: prereqPath,
		NoColor:      true,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, prereqOptions)
	}
	terraform.InitAndApply(t, prereqOptions)

	localCidr := []string{terraform.Output(t, prereqOptions, "local_cidr")}

	networkPath, _ := common.CopyTerraform(t, "./network", clusterSuffix)
	networkOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: networkPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name": clusterName,
			"region":       region,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer destroyGke(t, networkOptions, clusterName+"-network")
	}
	terraform.InitAndApply(t, networkOptions)

	networkName := terraform.Output(t, networkOptions, "network_name")
	subnetworkName := terraform.Output(t, networkOptions, "subnetwork_name")

	underTestPath, _ := common.CopyTerraform(t, "../../gke/terraform", clusterSuffix)
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             region,
			"kubernetes_version":                 KubernetesVersion,
			"create_network":                     false,
			"network_name":                       networkName,
			"subnetwork_name":                    subnetworkName,
			"secondary_range_name_services":      "services",
			"secondary_range_name_pods":          "pods",
			"master_ipv4_cidr_block":             "10.100.0.0/28",
			"create_bastion":                     false,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": localCidr,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	storageClassPath, _ := filepath.Abs("../../gke/kubernetes/storage-class.yaml")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":       clusterName,
			"region":             region,
			"storage_class_path": storageClassPath,
		},
		Upgrade: true,
	})

	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}
