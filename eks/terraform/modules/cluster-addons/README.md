<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.77.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.77.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_pod_identity"></a> [aws\_ebs\_csi\_pod\_identity](#module\_aws\_ebs\_csi\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 1.2.1 |
| <a name="module_aws_lb_controller_pod_identity"></a> [aws\_lb\_controller\_pod\_identity](#module\_aws\_lb\_controller\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 1.2.1 |
| <a name="module_aws_vpc_cni_pod_identity"></a> [aws\_vpc\_cni\_pod\_identity](#module\_aws\_vpc\_cni\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 1.2.1 |
| <a name="module_cluster_autoscaler_pod_identity"></a> [cluster\_autoscaler\_pod\_identity](#module\_cluster\_autoscaler\_pod\_identity) | terraform-aws-modules/eks-pod-identity/aws | 1.2.1 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.csi-driver](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube-proxy](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.pod-identity](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc-cni](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_addon) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the cluster. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags that are added to all resources created by this module, in the cases where this cannot be accomplished with 'default\_tags' on the AWS provider. | `map(string)` | `{}` | no |
| <a name="input_default_node_group_arn"></a> [default\_node\_group\_arn](#input\_default\_node\_group\_arn) | The ARN of the default node group. Some add-ons require this to be created before they can be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where this cluster will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_autoscaler_helm_values"></a> [cluster\_autoscaler\_helm\_values](#output\_cluster\_autoscaler\_helm\_values) | n/a |
| <a name="output_load_balancer_controller_helm_values"></a> [load\_balancer\_controller\_helm\_values](#output\_load\_balancer\_controller\_helm\_values) | n/a |
<!-- END_TF_DOCS -->