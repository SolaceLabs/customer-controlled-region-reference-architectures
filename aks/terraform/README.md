<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/bastion | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (VNET, Subnets, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | A list of CIDRs that can access the Kubernetes API, in addition to the VPC's CIDR (which is added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_admin_groups"></a> [kubernetes\_cluster\_admin\_groups](#input\_kubernetes\_cluster\_admin\_groups) | A list of Azure AD group object IDs that will have the Admin Role for the cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_cluster_admin_users"></a> [kubernetes\_cluster\_admin\_users](#input\_kubernetes\_cluster\_admin\_users) | A list of Azure AD users that will be assigned the 'Azure Kubernetes Service Cluster User Role' role for this cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_dns_service_ip"></a> [kubernetes\_dns\_service\_ip](#input\_kubernetes\_dns\_service\_ip) | The IP address within the service CIDR that will be used for kube-dns. | `string` | `"10.100.0.10"` | no |
| <a name="input_kubernetes_pod_cidr"></a> [kubernetes\_pod\_cidr](#input\_kubernetes\_pod\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `"10.101.0.0/16"` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `"10.100.0.0/16"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | By default, AKS has an admin account that can be used to access the cluster with static credentials. It's better to leave this disabled and use Azure RBAC, but it can be enabled if required. | `bool` | `true` | no |
| <a name="input_node_pool_max_size"></a> [node\_pool\_max\_size](#input\_node\_pool\_max\_size) | The maximum size for the broker node pools in the cluster. | `number` | `10` | no |
| <a name="input_outbound_ip_count"></a> [outbound\_ip\_count](#input\_outbound\_ip\_count) | The number of public IPs assigned to the load balancer that performs NAT for the VNET. | `number` | `2` | no |
| <a name="input_outbound_ports_allocated"></a> [outbound\_ports\_allocated](#input\_outbound\_ports\_allocated) | The number of outbound ports allocated for NAT for each VM within the VNET. | `number` | `896` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | When 'create\_network' is set to false, the route table ID must be provided. | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | When 'create\_network' is set to false, the subnet ID must be provided. | `string` | `""` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | The CIDR of the cluster's VNET and subnet. | `string` | `""` | no |
| <a name="input_worker_node_ssh_public_key"></a> [worker\_node\_ssh\_public\_key](#input\_worker\_node\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the worker nodes for SSH access. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#output\_kubernetes\_api\_public\_access) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END_TF_DOCS -->