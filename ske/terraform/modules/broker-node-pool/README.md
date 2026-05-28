<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_system_components"></a> [allow\_system\_components](#input\_allow\_system\_components) | StackIT-specific flag. Set to true only for the system pool that hosts cluster system workloads (CoreDNS, etc.). | `bool` | `false` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Zone suffixes. One node pool config object is produced per zone. Examples: ['1', '2'] for messaging, ['3'] for monitoring, ['m'] for metro / system. | `list(string)` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | StackIT VM flavor (e.g. m2i.2). | `string` | n/a | yes |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Per-pool autoscale maximum node count. | `number` | `5` | no |
| <a name="input_max_surge"></a> [max\_surge](#input\_max\_surge) | Upgrade max\_surge for the pool. | `number` | `1` | no |
| <a name="input_max_unavailable"></a> [max\_unavailable](#input\_max\_unavailable) | Upgrade max\_unavailable for the pool. | `number` | `1` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Per-pool autoscale minimum node count. | `number` | `0` | no |
| <a name="input_node_pool_labels"></a> [node\_pool\_labels](#input\_node\_pool\_labels) | Kubernetes labels applied to nodes in the pool. | `map(string)` | `{}` | no |
| <a name="input_node_pool_taints"></a> [node\_pool\_taints](#input\_node\_pool\_taints) | Kubernetes taints applied to nodes in the pool. | <pre>list(object({<br/>    key    = string<br/>    value  = string<br/>    effect = string<br/>  }))</pre> | `[]` | no |
| <a name="input_pool_name_prefix"></a> [pool\_name\_prefix](#input\_pool\_name\_prefix) | Pool name prefix. When length(availability\_zones) > 1, rendered pool names are prefix + '1', prefix + '2', etc.; otherwise the prefix is used unchanged. Example: prefix 'prod1k' + zones ['1', '2'] becomes 'prod1k1', 'prod1k2'. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | StackIT region (e.g. eu01). Used to construct full zone names as region + '-' + zone (e.g. eu01-1). | `string` | n/a | yes |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Root volume size in GiB for each node. Default is sized for Solace Cloud broker workloads. | `number` | `50` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | STACKIT block-storage performance class for the root volume (e.g. storage\_premium\_perf2). Default is suitable for Solace Cloud broker workloads. | `string` | `"storage_premium_perf2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pools"></a> [node\_pools](#output\_node\_pools) | List of node pool config objects, one per zone in var.availability\_zones. Shape matches the schema expected by stackit\_ske\_cluster.node\_pools. Calling code uses concat() to assemble multiple module outputs into the cluster's full node\_pools argument. |
<!-- END_TF_DOCS -->