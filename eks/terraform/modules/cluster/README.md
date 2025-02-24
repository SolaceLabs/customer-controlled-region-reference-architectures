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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_access_entry.admin](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.admin](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_cluster) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role) | resource |
| [aws_iam_role.worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.logs](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secrets](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.logs](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/kms_key) | resource |
| [aws_kms_key.secrets](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/kms_key_policy) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/security_group) | resource |
| [aws_security_group.worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_from_worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_node_from_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_node_to_worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_admin_arns"></a> [kubernetes\_cluster\_admin\_arns](#input\_kubernetes\_cluster\_admin\_arns) | User or role ARNs can be provided that will be given assigned AmazonEKSClusterAdminPolicy for this cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The IDs of the private subnets where the worker nodes will reside. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the cluster will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | n/a |
| <a name="output_worker_node_role_arn"></a> [worker\_node\_role\_arn](#output\_worker\_node\_role\_arn) | n/a |
| <a name="output_worker_node_security_group_id"></a> [worker\_node\_security\_group\_id](#output\_worker\_node\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->