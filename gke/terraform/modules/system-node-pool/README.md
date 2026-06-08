<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_container_node_pool.this](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/container_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones for the node pool. | `list(string)` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Labels that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version for the node pool. | `string` | n/a | yes |
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node) | The maximum number of pods per worker node for the node pool. | `number` | n/a | yes |
| <a name="input_node_pool_name"></a> [node\_pool\_name](#input\_node\_pool\_name) | The name the node pool. | `string` | n/a | yes |
| <a name="input_node_pool_size"></a> [node\_pool\_size](#input\_node\_pool\_size) | The number of worker nodes for the node pool (per zone). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_worker_node_machine_type"></a> [worker\_node\_machine\_type](#input\_worker\_node\_machine\_type) | The machine type used for the worker nodes in this node pool. | `string` | n/a | yes |
| <a name="input_worker_node_service_account"></a> [worker\_node\_service\_account](#input\_worker\_node\_service\_account) | The service account that will be assigned to the worker nodes in this node pool. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->