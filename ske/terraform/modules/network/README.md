<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_stackit"></a> [stackit](#requirement\_stackit) | ~> 0.95.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_stackit"></a> [stackit](#provider\_stackit) | ~> 0.95.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [stackit_network.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network) | resource |
| [stackit_network_area.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_area) | resource |
| [stackit_network_area_region.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_area_region) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_additional_sna_ranges"></a> [additional\_sna\_ranges](#input\_additional\_sna\_ranges) | Additional IPv4 prefixes added to the STACKIT Network Area, alongside cluster\_cidr. Commonly used for a VPN gateway range. Must not overlap with the CGNAT range (100.64.0.0/10). | `list(string)` | `[]` | no |
| <a name="input_cluster_cidr"></a> [cluster\_cidr](#input\_cluster\_cidr) | IPv4 CIDR for the cluster network and the primary prefix in the network area. Must not overlap with the CGNAT range (100.64.0.0/10). | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Map of resource labels to apply to all resources that support labelling. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for network resources. Produces name + '-sna' for the network area and name + '-network' for the network. | `string` | n/a | yes |
| <a name="input_network_dns_servers"></a> [network\_dns\_servers](#input\_network\_dns\_servers) | IPv4 nameservers configured on the cluster network. | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | STACKIT organization ID that owns the network area. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID where the project-scoped network is created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | STACKIT region used for the network area region binding (e.g. eu01). | `string` | n/a | yes |
| <a name="input_transfer_network_cidr"></a> [transfer\_network\_cidr](#input\_transfer\_network\_cidr) | IPv4 CIDR for the network area's transfer network. Must not overlap with the CGNAT range (100.64.0.0/10). | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_network_area_id"></a> [network\_area\_id](#output\_network\_area\_id) | ID of the organization-scoped network area. |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | ID of the project-scoped network. |
<!-- END_TF_DOCS -->