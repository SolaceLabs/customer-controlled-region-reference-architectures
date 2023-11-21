<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.81.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/virtual_machine) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group that will contain the network. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet where the bastion will reside. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | n/a |
<!-- END_TF_DOCS -->