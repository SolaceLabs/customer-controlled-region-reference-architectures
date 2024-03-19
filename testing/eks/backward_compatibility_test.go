package eks

import (
	"os"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformEksBackwardCompatibility(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	awsRegion := "us-west-2"
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

	vars := map[string]interface{}{
		"cluster_name":                       clusterName,
		"region":                             awsRegion,
		"kubernetes_version":                 KubernetesVersion,
		"vpc_cidr":                           "10.10.0.0/24",
		"public_subnet_cidrs":                []string{"10.10.0.0/28", "10.10.0.16/28", "10.10.0.32/28"},
		"private_subnet_cidrs":               []string{"10.10.0.64/26", "10.10.0.128/26", "10.10.0.192/26"},
		"bastion_ssh_authorized_networks":    localCidr,
		"bastion_ssh_public_key":             terraform.Output(t, prereqOptions, "bastion_ssh_public_key"),
		"kubernetes_api_public_access":       true,
		"kubernetes_api_authorized_networks": localCidr,
	}

	originalVersionPath := common.CopyTerraformFromRepository(t, "eks", "v1.1.0")
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

	latestVersionPath := common.CopyTerraform(t, "../../eks/terraform")
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
