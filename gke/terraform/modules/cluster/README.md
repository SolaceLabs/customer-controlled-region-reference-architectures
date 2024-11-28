<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_cluster.cluster](https://registry.terraform.io/providers/hashicorp/google/6.10.0/docs/resources/container_cluster) | resource |
| [google_service_account.cluster](https://registry.terraform.io/providers/hashicorp/google/6.10.0/docs/resources/service_account) | resource |
| [google_container_engine_versions.this](https://registry.terraform.io/providers/hashicorp/google/6.10.0/docs/data-sources/container_engine_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Labels that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publicly from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. Only used a creation time, ignored once the cluster exists. | `string` | n/a | yes |
| <a name="input_master_ipv4_cidr_block"></a> [master\_ipv4\_cidr\_block](#input\_master\_ipv4\_cidr\_block) | The CIDR used to assign IPs to the Kubernetes API endpoints. | `string` | n/a | yes |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network where the cluster will reside. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The GCP project that the cluster will reside in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region that the cluster will reside in. | `string` | n/a | yes |
| <a name="input_secondary_range_name_pods"></a> [secondary\_range\_name\_pods](#input\_secondary\_range\_name\_pods) | The name of the secondary CIDR range for the cluster's node pools. If a separate CIDR range is provided for messaging pods, this range will be used for just the system (default) node pool. | `string` | n/a | yes |
| <a name="input_secondary_range_name_services"></a> [secondary\_range\_name\_services](#input\_secondary\_range\_name\_services) | The name of the secondary CIDR range for the cluster's services. | `string` | n/a | yes |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | The name of the subnetwork where the cluster will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_master_version"></a> [master\_version](#output\_master\_version) | n/a |
| <a name="output_worker_node_service_account"></a> [worker\_node\_service\_account](#output\_worker\_node\_service\_account) | n/a |
<!-- END_TF_DOCS -->