<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.39.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.39.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster_autoscaler_irsa_role"></a> [cluster\_autoscaler\_irsa\_role](#module\_cluster\_autoscaler\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_ebs_csi_irsa_role"></a> [ebs\_csi\_irsa\_role](#module\_ebs\_csi\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_loadbalancer_controller_irsa_role"></a> [loadbalancer\_controller\_irsa\_role](#module\_loadbalancer\_controller\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_node_group_monitoring"></a> [node\_group\_monitoring](#module\_node\_group\_monitoring) | ../broker-node-group | n/a |
| <a name="module_node_group_prod100k"></a> [node\_group\_prod100k](#module\_node\_group\_prod100k) | ../broker-node-group | n/a |
| <a name="module_node_group_prod10k"></a> [node\_group\_prod10k](#module\_node\_group\_prod10k) | ../broker-node-group | n/a |
| <a name="module_node_group_prod1k"></a> [node\_group\_prod1k](#module\_node\_group\_prod1k) | ../broker-node-group | n/a |
| <a name="module_vpc_cni_irsa_role"></a> [vpc\_cni\_irsa\_role](#module\_vpc\_cni\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.default_name_tag](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_cloudwatch_log_group.cluster_logs](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_access_entry.admin](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.admin](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.csi-driver](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube-proxy](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc-cni](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.default](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role) | resource |
| [aws_iam_role.worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_node_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.logs](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/kms_alias) | resource |
| [aws_kms_alias.secrets](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/kms_alias) | resource |
| [aws_kms_key.logs](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/kms_key) | resource |
| [aws_kms_key.secrets](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/kms_key) | resource |
| [aws_kms_key_policy.logs](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/kms_key_policy) | resource |
| [aws_launch_template.default](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/launch_template) | resource |
| [aws_security_group.cluster](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/security_group) | resource |
| [aws_security_group.worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_from_worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_node_from_cluster](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.worker_node_to_worker_node](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/data-sources/partition) | data source |
| [tls_certificate.eks_oidc_issuer](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_admin_arns"></a> [kubernetes\_cluster\_admin\_arns](#input\_kubernetes\_cluster\_admin\_arns) | When kubernetes\_cluster\_auth\_mode is set to 'API', user or role ARNs can be provided that will be given assigned AmazonEKSClusterAdminPolicy for this cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_cluster_auth_mode"></a> [kubernetes\_cluster\_auth\_mode](#input\_kubernetes\_cluster\_auth\_mode) | This controls which authentication method to use for the cluster. See the readme for more details. | `string` | `null` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | The maximum size for the broker node groups in the cluster. | `number` | `10` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The IDs of the private subnets where the worker nodes will reside. | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the cluster will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_autoscaler_helm_values"></a> [cluster\_autoscaler\_helm\_values](#output\_cluster\_autoscaler\_helm\_values) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | n/a |
| <a name="output_default_node_group_arn"></a> [default\_node\_group\_arn](#output\_default\_node\_group\_arn) | n/a |
| <a name="output_load_balancer_controller_helm_values"></a> [load\_balancer\_controller\_helm\_values](#output\_load\_balancer\_controller\_helm\_values) | n/a |
| <a name="output_worker_node_role_arn"></a> [worker\_node\_role\_arn](#output\_worker\_node\_role\_arn) | n/a |
<!-- END_TF_DOCS -->