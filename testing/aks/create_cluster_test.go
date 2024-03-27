package aks

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const KubernetesVersion = "1.29"

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod1k", "managed-premium-zoned", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod1k", "managed-premium-zoned", 2)

	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod10k", "managed-premium-zoned", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod10k", "managed-premium-zoned", 2)

	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod100k", "managed-premium-zoned", 1)

	common.PrintTestComplete(t)
}

func TestTerraformAksClusterComplete(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	azureRegion := "eastus2"
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

	underTestPath := common.CopyTerraform(t, "../../aks/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             azureRegion,
			"kubernetes_version":                 KubernetesVersion,
			"vnet_cidr":                          "10.10.0.0/24",
			"bastion_ssh_authorized_networks":    localCidr,
			"bastion_ssh_public_key":             bastionPublicKey,
			"worker_node_ssh_public_key":         bastionPublicKey,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": localCidr,
			"local_account_disabled":             false,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}

	terraform.InitAndApply(t, underTestOptions)

	storageClassPath, _ := filepath.Abs("../../aks/kubernetes/storage-class.yaml")

	configPath := common.CopyTerraform(t, "./configuration")
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"resource_group_name": fmt.Sprintf("%s-cluster", clusterName),
			"cluster_name":        clusterName,
			"storage_class_path":  storageClassPath,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")

	common.TestSshToBastionHost(t, bastionPublicIp, "ubuntu", bastionPrivateKey)

	testCluster(t, configOptions)
}

func TestTerraformAksClusterExternalNetwork(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	azureRegion := "eastus2"
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
	bastionPublicKey := terraform.Output(t, prereqOptions, "bastion_ssh_public_key")

	networkPath := common.CopyTerraform(t, "./network")
	networkOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: networkPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name": clusterName,
			"region":       azureRegion,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, networkOptions)
	}
	terraform.InitAndApply(t, networkOptions)

	subnetId := terraform.Output(t, networkOptions, "subnet_id")
	routeTableId := terraform.Output(t, networkOptions, "route_table_id")

	underTestPath := common.CopyTerraform(t, "../../aks/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             azureRegion,
			"kubernetes_version":                 KubernetesVersion,
			"create_network":                     false,
			"subnet_id":                          subnetId,
			"route_table_id":                     routeTableId,
			"create_bastion":                     false,
			"worker_node_ssh_public_key":         bastionPublicKey,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": localCidr,
			"local_account_disabled":             false,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}

	terraform.InitAndApply(t, underTestOptions)

	storageClassPath, _ := filepath.Abs("../../aks/kubernetes/storage-class.yaml")

	configPath := common.CopyTerraform(t, "./configuration")
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"resource_group_name": fmt.Sprintf("%s-cluster", clusterName),
			"cluster_name":        clusterName,
			"storage_class_path":  storageClassPath,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	testCluster(t, configOptions)
}
