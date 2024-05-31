<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.94.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.94.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster_node_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/kubernetes_cluster_node_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones for the node pools - one pool is created in each zone. | `list(string)` | n/a | yes |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | The ID of the cluster. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_node_pool_labels"></a> [node\_pool\_labels](#input\_node\_pool\_labels) | Kubernetes labels added to worker nodes in the node pools. | `map(string)` | n/a | yes |
| <a name="input_node_pool_max_size"></a> [node\_pool\_max\_size](#input\_node\_pool\_max\_size) | The maximum worker node count for each node pool. | `string` | n/a | yes |
| <a name="input_node_pool_name"></a> [node\_pool\_name](#input\_node\_pool\_name) | The name prefix of the node pools. | `string` | n/a | yes |
| <a name="input_node_pool_taints"></a> [node\_pool\_taints](#input\_node\_pool\_taints) | Kubernetes taints added to worker nodes in the node pools. | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet that will contain the worker nodes in each node pool. | `string` | n/a | yes |
| <a name="input_worker_node_disk_size"></a> [worker\_node\_disk\_size](#input\_worker\_node\_disk\_size) | The OS disk size (in GB) used for the worker nodes in each node pool. | `string` | n/a | yes |
| <a name="input_worker_node_max_pods"></a> [worker\_node\_max\_pods](#input\_worker\_node\_max\_pods) | The maximum number of pods for the worker nodes in the node pools. | `number` | n/a | yes |
| <a name="input_worker_node_vm_size"></a> [worker\_node\_vm\_size](#input\_worker\_node\_vm\_size) | The VM size used for the worker nodes in each node pool. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->