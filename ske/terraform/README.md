<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.95.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | 0.95.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/bastion | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_node_pool_monitoring"></a> [node\_pool\_monitoring](#module\_node\_pool\_monitoring) | ./modules/broker-node-pool | n/a |
| <a name="module_node_pool_prod100k"></a> [node\_pool\_prod100k](#module\_node\_pool\_prod100k) | ./modules/broker-node-pool | n/a |
| <a name="module_node_pool_prod10k"></a> [node\_pool\_prod10k](#module\_node\_pool\_prod10k) | ./modules/broker-node-pool | n/a |
| <a name="module_node_pool_prod1k"></a> [node\_pool\_prod1k](#module\_node\_pool\_prod1k) | ./modules/broker-node-pool | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [stackit_resourcemanager_project.cluster](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/resourcemanager_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_sna_ranges"></a> [additional\_sna\_ranges](#input\_additional\_sna\_ranges) | Additional IPv4 prefixes added to the STACKIT Network Area, alongside cluster\_cidr. Commonly used for a VPN gateway range. | `list(string)` | <pre>[<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_bastion_icmp_source_cidr"></a> [bastion\_icmp\_source\_cidr](#input\_bastion\_icmp\_source\_cidr) | Source CIDR allowed to send ICMP echo (ping) to the bastion. Leave empty to omit the ICMP ingress rule entirely. | `string` | `""` | no |
| <a name="input_bastion_image_id"></a> [bastion\_image\_id](#input\_bastion\_image\_id) | STACKIT image UUID for the bastion VM. Required when create\_bastion is true. Find current Ubuntu UUIDs via `stackit image list --project-id <any-org-project>` filtered to distro=ubuntu. | `string` | `""` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | SSH public key string installed on the bastion. Required when create\_bastion is true. | `string` | `""` | no |
| <a name="input_bastion_ssh_source_cidr"></a> [bastion\_ssh\_source\_cidr](#input\_bastion\_ssh\_source\_cidr) | Source CIDR allowed to SSH to the bastion (port 22). Required when create\_bastion is true. | `string` | `""` | no |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input\_cluster\_cidr) | IPv4 CIDR for the cluster network. | `string` | `"10.0.0.0/24"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name used for the SKE cluster, project, and as a prefix for network resources. Max 11 characters (STACKIT SKE limit). | `string` | n/a | yes |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host with a public IP. | `bool` | `false` | no |
| <a name="input_kubernetes_api_access_scope"></a> [kubernetes\_api\_access\_scope](#input\_kubernetes\_api\_access\_scope) | Control plane access scope. PUBLIC exposes the Kubernetes API to the internet; PRIVATE restricts to the cluster network. | `string` | `"PUBLIC"` | no |
| <a name="input_network_dns_servers"></a> [network\_dns\_servers](#input\_network\_dns\_servers) | IPv4 nameservers configured on the cluster network. | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_node_pool_max_size"></a> [node\_pool\_max\_size](#input\_node\_pool\_max\_size) | Maximum number of nodes for messaging and monitoring node pools. | `number` | `10` | no |
| <a name="input_node_pool_volume_size"></a> [node\_pool\_volume\_size](#input\_node\_pool\_volume\_size) | Root volume size in GiB for each node pool. Default is sized for Solace Cloud broker workloads. | `number` | `50` | no |
| <a name="input_node_pool_volume_type"></a> [node\_pool\_volume\_type](#input\_node\_pool\_volume\_type) | STACKIT block-storage performance class for each node pool's root volume. Default is suitable for Solace Cloud broker workloads. | `string` | `"storage_premium_perf2"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | STACKIT organization ID under which the network area and project are created. | `string` | n/a | yes |
| <a name="input_owner_email"></a> [owner\_email](#input\_owner\_email) | Owner email assigned to the STACKIT project. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | STACKIT region to deploy resources into. | `string` | `"eu01"` | no |
| <a name="input_transfer_network_cidr"></a> [transfer\_network\_cidr](#input\_transfer\_network\_cidr) | IPv4 CIDR for the network area's transfer network. | `string` | `"10.1.0.0/16"` | no |
| <a name="input_worker_node_pool_min_size"></a> [worker\_node\_pool\_min\_size](#input\_worker\_node\_pool\_min\_size) | Minimum number of nodes for messaging and monitoring node pools. | `number` | `0` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion host (null when create\_bastion is false). |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | SSH username for the bastion host (null when create\_bastion is false). |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the SKE cluster. |
| <a name="output_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#output\_kubernetes\_api\_public\_access) | Whether the cluster's Kubernetes API is publicly accessible. Derived from kubernetes\_api\_access\_scope; matches the AKS/EKS/GKE output name so connect.sh can use the same logic. |
| <a name="output_network_area_id"></a> [network\_area\_id](#output\_network\_area\_id) | ID of the organization-scoped STACKIT network area. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | ID of the project-scoped network. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created STACKIT project. |
<!-- END_TF_DOCS -->