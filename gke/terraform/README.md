<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

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
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Labels that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (network, subnetworks, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The CIDR used to assign IPs to the Kubernetes API endpoints. This range must be unique within the VPC. | `string` | `"172.16.0.32/28"` | no |
| <a name="input_max_pods_per_node_messaging"></a> [max\_pods\_per\_node\_messaging](#input\_max\_pods\_per\_node\_messaging) | The maximum number of pods per worker node for the messaging node pools. | `number` | `8` | no |
| <a name="input_max_pods_per_node_system"></a> [max\_pods\_per\_node\_system](#input\_max\_pods\_per\_node\_system) | The maximum number of pods per worker node for the system node pool. | `number` | `16` | no |
| <a name="input_network_cidr_range"></a> [network\_cidr\_range](#input\_network\_cidr\_range) | The CIDR for the cluster's network. Worker nodes, load balancers, and other infrastructure is assigned an IP address from this range. | `string` | `""` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | When 'create\_network' is set to false, the network name must be provided. | `string` | `""` | no |
| <a name="input_node_pool_max_size"></a> [node\_pool\_max\_size](#input\_node\_pool\_max\_size) | The maximum number of worker nodes for the messaging node pools. | `string` | `20` | no |
| <a name="input_project"></a> [project](#input\_project) | The GCP project that the cluster will reside in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region that the cluster will reside in. | `string` | n/a | yes |
| <a name="input_secondary_cidr_range_pods"></a> [secondary\_cidr\_range\_pods](#input\_secondary\_cidr\_range\_pods) | The secondary CIDR for the cluster's pods. GKE assigns each worker node a /24 for pods from this address range. | `string` | n/a | yes |
| <a name="input_secondary_cidr_range_services"></a> [secondary\_cidr\_range\_services](#input\_secondary\_cidr\_range\_services) | The secondary CIDR for the cluster's services. Cluster IP services are assigned an IP from this addres range. | `string` | n/a | yes |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | When 'create\_network' is set to false, the subnetwork name must be provided. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#output\_kubernetes\_api\_public\_access) | n/a |
| <a name="output_project"></a> [project](#output\_project) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
<!-- END_TF_DOCS -->