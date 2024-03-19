package aks

import (
	"os"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformAksBackwardCompatibility(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	azureRegion := "westus2"
	clusterName := "terratest-compat"

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

	vars := map[string]interface{}{
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
	}

	originalVersionPath := common.CopyTerraformFromRepository(t, "aks", "v1.1.0")
	originalVersionOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: originalVersionPath,
		NoColor:      true,
		Vars:         vars,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, originalVersionOptions)
	}
	terraform.InitAndApply(t, originalVersionOptions)

	latestVersionPath := common.CopyTerraform(t, "../../aks/terraform")
	common.CopyTerraformState(t, originalVersionPath, latestVersionPath)
	latestVersionOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: latestVersionPath,
		NoColor:      true,
		Vars:         vars,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, latestVersionOptions)
	}
	terraform.InitAndApply(t, latestVersionOptions)
}
