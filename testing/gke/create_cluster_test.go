package gke

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Prerequisite, set the GCP project with: export TF_VAR_project=<project>

const KubernetesVersion = "1.29"

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod1k", "ssd", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod1k", "ssd", 2)

	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod10k", "ssd", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod10k", "ssd", 2)

	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod100k", "ssd", 1)

	common.PrintTestComplete(t)
}

func TestTerraformGkeClusterComplete(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	region := "europe-west1"
	clusterName := "terratest-complete"

	prereqPath := common.CopyTerraform(t, "../prerequisites")
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
	bastionPublicKey := terraform.Output(t, prereqOptions, "bastion_ssh_public_key")

	underTestPath := common.CopyTerraform(t, "../../gke/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             region,
			"kubernetes_version":                 KubernetesVersion,
			"network_cidr_range":                 "10.10.0.0/24",
			"secondary_cidr_range_pods":          "10.11.0.0/16",
			"secondary_cidr_range_services":      "10.12.0.0/16",
			"master_ipv4_cidr_block":             "10.100.0.0/28",
			"bastion_ssh_authorized_networks":    localCidr,
			"bastion_ssh_public_key":             bastionPublicKey,
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

	configPath := common.CopyTerraform(t, "./configuration")
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

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")

	common.TestSshToBastionHost(t, bastionPublicIp, "ubuntu", bastionPrivateKey)

	testCluster(t, configOptions)
}

func TestTerraformGkeClusterExternalNetwork(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	region := "us-east1"
	clusterName := "terratest-network"

	prereqPath := common.CopyTerraform(t, "../prerequisites")
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

	networkPath := common.CopyTerraform(t, "./network")
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
		defer terraform.Destroy(t, networkOptions)
	}
	terraform.InitAndApply(t, networkOptions)

	networkName := terraform.Output(t, networkOptions, "network_name")
	subnetworkName := terraform.Output(t, networkOptions, "subnetwork_name")

	underTestPath := common.CopyTerraform(t, "../../gke/terraform")
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
			"network_cidr_range":                 "10.10.0.0/24",
			"secondary_cidr_range_pods":          "10.11.0.0/16",
			"secondary_cidr_range_services":      "10.12.0.0/16",
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

	configPath := common.CopyTerraform(t, "./configuration")
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
