package aks

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Prerequisite, set the Azure subscription with: export TF_VAR_subscription=<subscription>

const KubernetesVersion = "1.33"

func destroyAks(t *testing.T, options *terraform.Options) {
	if _, err := terraform.DestroyE(t, options); err == nil {
		return
	}
	terraform.Destroy(t, options)
}

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	storageClass := "managed-premium-zoned"

	serviceClassTests := []struct {
		name            string
		serviceClass    string
		highlyAvailable bool
		serviceCount    int
	}{
		{"prod1k-ha", "prod1k", true, 1},
		{"prod1k-standalone", "prod1k", false, 2},
		{"prod5k-standalone", "prod5k", false, 2},
		{"prod10k-ha", "prod10k", true, 1},
		{"prod10k-standalone", "prod10k", false, 2},
		{"prod50k-standalone", "prod50k", false, 1},
		{"prod100k-standalone", "prod100k", false, 1},
	}

	t.Run("validate", func(t *testing.T) {
		for _, tc := range serviceClassTests {
			tc := tc
			t.Run(tc.name, func(t *testing.T) {
				t.Parallel()
				if tc.highlyAvailable {
					common.TestHighAvailableServiceClass(t, kubeconfigPath, tc.serviceClass, storageClass, tc.serviceCount)
				} else {
					common.TestStandaloneServiceClass(t, kubeconfigPath, tc.serviceClass, storageClass, tc.serviceCount)
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

func TestTerraformAksClusterComplete(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	clusterSuffix := os.Getenv("CLUSTER_SUFFIX")
	if clusterSuffix == "" {
		clusterSuffix = common.UniqueId(6)
	}

	azureRegion := "eastus2"
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

	underTestPath, _ := common.CopyTerraform(t, "../../aks/terraform", clusterSuffix)
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             azureRegion,
			"kubernetes_version":                 KubernetesVersion,
			"vnet_cidr":                          "10.10.0.0/24",
			"bastion_ssh_authorized_networks":    []string{"0.0.0.0/0"},
			"bastion_ssh_public_key":             bastionPublicKey,
			"worker_node_ssh_public_key":         bastionPublicKey,
			"kubernetes_api_public_access":       false,
			"kubernetes_api_authorized_networks": []string{},
			"local_account_disabled":             false,
			"common_tags":                        common.GenerateTags(clusterName),
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer destroyAks(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")

	common.TestSshToBastionHost(t, bastionPublicIp, "ubuntu", bastionPrivateKey)

	proxyUrl, stopProxy := common.StartSocksProxyThroughBastion(t, bastionPublicIp, "ubuntu", bastionPrivateKey)
	defer stopProxy()

	storageClassPath, _ := filepath.Abs("../../aks/kubernetes/storage-class.yaml")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"resource_group_name": fmt.Sprintf("%s-cluster", clusterName),
			"cluster_name":        clusterName,
			"storage_class_path":  storageClassPath,
			"proxy_url":           proxyUrl,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}

func TestTerraformAksClusterExternalNetwork(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	clusterSuffix := os.Getenv("CLUSTER_SUFFIX")
	if clusterSuffix == "" {
		clusterSuffix = common.UniqueId(6)
	}

	azureRegion := "eastus2"
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
	bastionPublicKey := terraform.Output(t, prereqOptions, "bastion_ssh_public_key")

	networkPath, _ := common.CopyTerraform(t, "./network", clusterSuffix)
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

	underTestPath, _ := common.CopyTerraform(t, "../../aks/terraform", clusterSuffix)
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
		defer destroyAks(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	storageClassPath, _ := filepath.Abs("../../aks/kubernetes/storage-class.yaml")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
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

	testCluster(t, configOptions)
}
