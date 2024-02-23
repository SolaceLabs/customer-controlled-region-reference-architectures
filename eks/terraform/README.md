<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/bastion | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_public_access"></a> [bastion\_public\_access](#input\_bastion\_public\_access) | When set to true the bastion host is assigned a public IP and can be access from any of the networks provided in the 'bastion\_ssh\_authorized\_networks' parameter. | `bool` | `true` | no |
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (VPC, Subnets, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_access"></a> [kubernetes\_cluster\_access](#input\_kubernetes\_cluster\_access) | This controls which authentication method to use for the cluster. See the readme for more details. | `string` | `"ConfigMap"` | no |
| <a name="input_kubernetes_cluster_admin_arns"></a> [kubernetes\_cluster\_admin\_arns](#input\_kubernetes\_cluster\_admin\_arns) | When kubernetes\_cluster\_access is set to 'API', user or role ARNs can be provided that will be given assigned AmazonEKSClusterAdminPolicy for this cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `"10.100.0.0/16"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | The maximum size for the broker node groups in the cluster. | `number` | `10` | no |
| <a name="input_pod_spread_policy"></a> [pod\_spread\_policy](#input\_pod\_spread\_policy) | This controls which AZs host node groups for the primary, backup, and monitor node pools as well as which AZs will host the ENIs for the NLBs that front each event broker service. See the readme for more details. | `string` | `"full"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | The CIDRs of the three private subnets. These will contain the EKS cluster's master ENIs, worker nodes, and internal load-balancer ENIs (if desired). | `list(string)` | `[]` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | When 'create\_network' is set to false, the private subnet IDs must be provided. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | The CIDRs of the three public subnets. These will contain the bastion host, NAT gateways, and internet-facing load balancer ENIs (if desired). | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR of the cluster's VPC. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | When 'create\_network' is set to false, the VPC ID must be provided. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_cluster_autoscaler_helm_values"></a> [cluster\_autoscaler\_helm\_values](#output\_cluster\_autoscaler\_helm\_values) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#output\_kubernetes\_api\_public\_access) | n/a |
| <a name="output_load_balancer_controller_helm_values"></a> [load\_balancer\_controller\_helm\_values](#output\_load\_balancer\_controller\_helm\_values) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
<!-- END_TF_DOCS -->