package eks

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/SolaceDev/sc-private-regions-terraform/testing/common"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/terraform"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// cluster autoscaler version must match kubernetes version
const KubernetesVersion = "1.28"
const ClusterAutoscalerVersion = "v1.28.2"

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	options := k8s.NewKubectlOptions("", kubeconfigPath, "kube-system")

	k8s.WaitUntilNumPodsCreated(t, options, metav1.ListOptions{LabelSelector: "app.kubernetes.io/name=aws-cluster-autoscaler"}, 2, 30, 5*time.Second)
	k8s.WaitUntilNumPodsCreated(t, options, metav1.ListOptions{LabelSelector: "app.kubernetes.io/name=aws-load-balancer-controller"}, 2, 30, 5*time.Second)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp2-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp3", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp3", []string{"./service-annotations.yaml"}, 2, false)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp2-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp3", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp3", []string{"./service-annotations.yaml"}, 2, false)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod100k", "gp2-test", []string{"./service-annotations.yaml"}, 1, false)

	common.PrintTestComplete(t)
}

func TestTerraformEksClusterComplete(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	awsRegion := "eu-west-2"
	clusterName := "terratest-complete"

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites")
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

	underTestPath, _ := common.CopyTerraform(t, "../../eks/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
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
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	configPath, _ := common.CopyTerraform(t, "./configuration")
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                         clusterName,
			"region":                               awsRegion,
			"cluster_autoscaler_helm_values":       autoscalerValues,
			"load_balancer_controller_helm_values": loadBalancerValues,
			"storage_class_path_gp2":               storageClassPathGp2,
			"storage_class_path_gp3":               storageClassPathGp3,
			"cluster_autoscaler_version":           ClusterAutoscalerVersion,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	bastionPublicIp := terraform.Output(t, underTestOptions, "bastion_public_ip")
	bastionPrivateKey := terraform.Output(t, prereqOptions, "bastion_ssh_private_key")
	common.TestSshToBastionHost(t, bastionPublicIp, "ec2-user", bastionPrivateKey)

	testCluster(t, configOptions)
}

func TestTerraformEksClusterFixedZones(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	awsRegion := "eu-west-1"
	clusterName := "terratest-fixed-zones"

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites")
	prereqOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: prereqPath,
		NoColor:      true,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, prereqOptions)
	}
	terraform.InitAndApply(t, prereqOptions)

	underTestPath, _ := common.CopyTerraform(t, "../../eks/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             awsRegion,
			"kubernetes_version":                 KubernetesVersion,
			"vpc_cidr":                           "10.10.0.0/24",
			"public_subnet_cidrs":                []string{"10.10.0.0/28", "10.10.0.16/28", "10.10.0.32/28"},
			"private_subnet_cidrs":               []string{"10.10.0.64/26", "10.10.0.128/26", "10.10.0.192/26"},
			"create_bastion":                     false,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": []string{terraform.Output(t, prereqOptions, "local_cidr")},
			"pod_spread_policy":                  "fixed",
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	configPath, _ := common.CopyTerraform(t, "./configuration")
	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: configPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                         clusterName,
			"region":                               awsRegion,
			"cluster_autoscaler_helm_values":       terraform.Output(t, underTestOptions, "cluster_autoscaler_helm_values"),
			"load_balancer_controller_helm_values": terraform.Output(t, underTestOptions, "load_balancer_controller_helm_values"),
			"storage_classes":                      getStorageClassList(),
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}

func TestTerraformEksClusterExternalNetwork(t *testing.T) {
	t.Parallel()

	keepCluster := os.Getenv("KEEP_CLUSTER")

	awsRegion := "eu-west-3"
	clusterName := "terratest-network"

	prereqPath, _ := common.CopyTerraform(t, "../prerequisites")
	prereqOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: prereqPath,
		NoColor:      true,
		Upgrade:      true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, prereqOptions)
	}
	terraform.InitAndApply(t, prereqOptions)

	networkPath, _ := common.CopyTerraform(t, "./network")
	networkOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: networkPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name": clusterName,
			"region":       awsRegion,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, networkOptions)
	}
	terraform.InitAndApply(t, networkOptions)

	underTestPath, _ := common.CopyTerraform(t, "../../eks/terraform")
	underTestOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: underTestPath,
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                       clusterName,
			"region":                             awsRegion,
			"kubernetes_version":                 KubernetesVersion,
			"create_network":                     false,
			"vpc_id":                             terraform.Output(t, networkOptions, "vpc_id"),
			"private_subnet_ids":                 terraform.OutputList(t, networkOptions, "private_subnets"),
			"create_bastion":                     false,
			"kubernetes_api_public_access":       true,
			"kubernetes_api_authorized_networks": []string{terraform.Output(t, prereqOptions, "local_cidr")},
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, underTestOptions)
	}
	terraform.InitAndApply(t, underTestOptions)

	configOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./configuration",
		NoColor:      true,
		Vars: map[string]interface{}{
			"cluster_name":                         clusterName,
			"region":                               awsRegion,
			"cluster_autoscaler_helm_values":       autoscalerValues,
			"load_balancer_controller_helm_values": loadBalancerValues,
			"storage_class_path_gp2":               storageClassPathGp2,
			"storage_class_path_gp3":               storageClassPathGp3,
			"cluster_autoscaler_version":           ClusterAutoscalerVersion,
		},
		Upgrade: true,
	})

	if keepCluster != "yes" {
		defer terraform.Destroy(t, configOptions)
	}
	terraform.InitAndApply(t, configOptions)

	testCluster(t, configOptions)
}

func testCluster(t *testing.T, configOptions *terraform.Options) {
	kubeconfig := terraform.Output(t, configOptions, "kubeconfig")
	kubeconfigPath := common.WriteKubeconfigToTempFile(kubeconfig)
	defer os.Remove(kubeconfigPath)

	options := k8s.NewKubectlOptions("", kubeconfigPath, "kube-system")

	k8s.WaitUntilNumPodsCreated(t, options, metav1.ListOptions{LabelSelector: "app.kubernetes.io/name=aws-cluster-autoscaler"}, 2, 30, 5*time.Second)
	k8s.WaitUntilNumPodsCreated(t, options, metav1.ListOptions{LabelSelector: "app.kubernetes.io/name=aws-load-balancer-controller"}, 2, 30, 5*time.Second)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp2-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp3-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod1k", "gp3-test", []string{"./service-annotations.yaml"}, 2, false)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp2-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp3-test", []string{"./service-annotations.yaml"}, 1, true)
	common.TestServiceClassWithValues(t, kubeconfigPath, "prod10k", "gp3-test", []string{"./service-annotations.yaml"}, 2, false)

	common.TestServiceClassWithValues(t, kubeconfigPath, "prod100k", "gp2-test", []string{"./service-annotations.yaml"}, 1, false)

	common.PrintTestComplete(t)
}

func getStorageClassList() []interface{} {
	gp2, _ := filepath.Abs("../../eks/kubernetes/storage-class-gp2.yaml")
	gp3, _ := filepath.Abs("../../eks/kubernetes/storage-class-gp3.yaml")

	return []interface{}{
		map[string]interface{}{
			"name": "gp2-test",
			"path": gp2,
		},
		map[string]interface{}{
			"name": "gp3-test",
			"path": gp3,
		},
	}
}
