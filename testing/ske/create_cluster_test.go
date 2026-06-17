package ske

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

// Prerequisite: set STACKIT credentials and the following environment variables:
//   export TF_VAR_organization_id=<stackit-org-id>
//   export TF_VAR_owner_email=<owner-email>

const KubernetesVersion = "1.35"
const suffixFile = ".cluster-suffix"

// getOrCreateSuffix returns a stable cluster suffix. On first run it generates
// a random suffix and writes it to .cluster-suffix. On subsequent runs it reads
// from that file, so the test targets the same infrastructure. Delete the file
// to get a fresh suffix.
func getOrCreateSuffix(t *testing.T) string {
	// Environment variable takes highest priority
	if envSuffix := os.Getenv("CLUSTER_SUFFIX"); envSuffix != "" {
		return envSuffix
	}

	// Try reading a persisted suffix from a local file
	if data, err := os.ReadFile(suffixFile); err == nil {
		suffix := strings.TrimSpace(string(data))
		if suffix != "" {
			logger.Log(t, fmt.Sprintf("Using persisted cluster suffix from %s: %s", suffixFile, suffix))
			return suffix
		}
	}

	// Generate a new suffix and persist it
	suffix := common.UniqueId(6)
	os.WriteFile(suffixFile, []byte(suffix), 0644)
	logger.Log(t, fmt.Sprintf("Generated new cluster suffix (persisted to %s): %s", suffixFile, suffix))
	return suffix
}

func testCluster(t *testing.T, kubeconfigPath string) {
	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod1k", "solace-default", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod1k", "solace-default", 2)

	common.TestHighAvailableServiceClass(t, kubeconfigPath, "prod10k", "solace-default", 1)
	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod10k", "solace-default", 2)

	common.TestStandaloneServiceClass(t, kubeconfigPath, "prod100k", "solace-default", 1)

	common.PrintTestComplete(t)
}

func applyStorageClasses(t *testing.T, kubeconfigPath string) {
	options := k8s.NewKubectlOptions("", kubeconfigPath, "")

	storageClassDataPath, _ := filepath.Abs("../../ske/kubernetes/storage-class-data.yaml")
	storageClassSpoolPath, _ := filepath.Abs("../../ske/kubernetes/storage-class-spool.yaml")

	k8s.KubectlApply(t, options, storageClassDataPath)
	k8s.KubectlApply(t, options, storageClassSpoolPath)
}

func formatVars(vars map[string]any) string {
	var sb strings.Builder

	for k, v := range vars {
		switch val := v.(type) {
		case string:
			fmt.Fprintf(&sb, "%v = %q\n", k, val)
		case []string:
			quoted := make([]string, len(val))
			for i, s := range val {
				quoted[i] = fmt.Sprintf("%q", s)
			}
			fmt.Fprintf(&sb, "%v = [%s]\n", k, strings.Join(quoted, ","))
		default:
			fmt.Fprintf(&sb, "%v = %v\n", k, val)
		}
	}

	return sb.String()
}

func writeVarFile(t *testing.T, name string, targetDir string, vars map[string]any) {
	file, err := os.Create(fmt.Sprintf("%v/%v.tfvars",targetDir,name))
	if err != nil {
	  logger.Log(t,err)
	}
	defer file.Close()

	varString := formatVars(vars)
	fmt.Fprintf(file, varString)
}

func TestTerraformSkeClusterComplete(t *testing.T) {
	keepCluster := os.Getenv("KEEP_CLUSTER")
	clusterSuffix := getOrCreateSuffix(t)

	region := "eu01"
	clusterName := fmt.Sprintf("tt-%s", clusterSuffix) // SKE limits cluster names to 11 characters

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

	underTestPath, _ := common.CopyTerraform(t, "../../ske/terraform", clusterSuffix)
	vars := map[string]any{
			"cluster_name":                       clusterName,
			"region":                             region,
			"kubernetes_version":                 KubernetesVersion,
			"cluster_cidr":                       "10.10.0.0/24",
			"worker_node_pool_min_size":          1,
			"create_bastion":                     true,
			"bastion_image_id":                   "3ad2867e-695b-4ee6-9502-b563013413d4",
			"bastion_ssh_public_key":             bastionPublicKey,
			"bastion_ssh_source_cidrs":           localCidr,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": localCidr,
	}
	writeVarFile(t, clusterSuffix, underTestPath, vars)
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor: true,
		Vars: vars,
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}

	terraform.InitAndApply(t, underTestOptions)

	projectId := terraform.Output(t, underTestOptions, "project_id")

	configPath, _ := common.CopyTerraform(t, "./configuration", clusterSuffix)
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]any{
			"project_id":   projectId,
			"cluster_name": clusterName,
			"region":       region,
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

	applyStorageClasses(t, kubeconfigPath)

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")

	common.TestSshToBastionHost(t, bastionPublicIp, "ubuntu", bastionPrivateKey)

	testCluster(t, kubeconfigPath)
}
