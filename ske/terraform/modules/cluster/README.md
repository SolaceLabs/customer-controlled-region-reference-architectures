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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [stackit_ske_cluster.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/ske_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the SKE cluster. STACKIT limits cluster names to 11 characters. | `string` | n/a | yes |
| <a name="input_kubernetes_api_access_scope"></a> [kubernetes\_api\_access\_scope](#input\_kubernetes\_api\_access\_scope) | Control plane access scope. PUBLIC exposes the Kubernetes API to the internet; PRIVATE restricts access to the cluster network. | `string` | `"PUBLIC"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | STACKIT network ID that the cluster's nodes attach to. | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List of node pool config objects to apply to the cluster. STACKIT requires node pools to be defined inline on stackit\_ske\_cluster; assemble the list at the calling layer (e.g. via broker-node-pool module outputs). | `any` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID where the cluster is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the SKE cluster. |
<!-- END_TF_DOCS -->