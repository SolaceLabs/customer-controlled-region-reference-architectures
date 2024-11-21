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
| [azurerm_route.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/route) | resource |
| [azurerm_route_table.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/route_table) | resource |
| [azurerm_subnet.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/subnet) | resource |
| [azurerm_subnet_route_table_association.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/3.94.0/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster. | `string` | n/a | yes |
| <a name="input_cluster_subnet_cidr"></a> [cluster\_subnet\_cidr](#input\_cluster\_subnet\_cidr) | The CIDR of the cluster's subnet. | `string` | `null` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (VNET, Subnets, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region where this network will reside. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group that will contain the network. | `string` | n/a | yes |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | The CIDR of the cluster's VNET. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
<!-- END_TF_DOCS -->