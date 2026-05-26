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
| [stackit_key_pair.bastion_kp](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/key_pair) | resource |
| [stackit_network_interface.bastion_nic](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_public_ip.bastion_public_ip](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_security_group.bastion_sg](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group) | resource |
| [stackit_security_group_rule.icmp](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_security_group_rule.ssh](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_server.bastion](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bastion_icmp_source_cidr"></a> [bastion\_icmp\_source\_cidr](#input\_bastion\_icmp\_source\_cidr) | Source CIDR allowed to send ICMP echo (ping) to the bastion. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_bastion_image_id"></a> [bastion\_image\_id](#input\_bastion\_image\_id) | STACKIT image UUID for the bastion VM. Required when create\_bastion is true. Find current Ubuntu UUIDs via `stackit image list --project-id <any-org-project>` filtered to distro=ubuntu. | `string` | `""` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | SSH public key string installed on the bastion. Required when create\_bastion is true. | `string` | `""` | no |
| <a name="input_bastion_ssh_source_cidr"></a> [bastion\_ssh\_source\_cidr](#input\_bastion\_ssh\_source\_cidr) | Source CIDR allowed to SSH to the bastion (port 22). STACKIT security group rules accept a single CIDR per rule; for multiple sources, extend the module. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_boot_volume_size"></a> [boot\_volume\_size](#input\_boot\_volume\_size) | Boot volume size in GiB for the bastion host. | `number` | `16` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name. Used as a prefix for bastion resource names (e.g. cluster\_name + '-bastion', cluster\_name + '-bastion-sg', cluster\_name + '-bastion-kp'). | `string` | n/a | yes |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. When false, no resources are created and outputs are null. | `bool` | `false` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | STACKIT VM flavor for the bastion host. | `string` | `"g2i.1"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network ID for the bastion's NIC. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID where the bastion is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | The bastion host's public IP address. Null when create\_bastion is false. |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | The bastion host's SSH username. Null when create\_bastion is false. |
<!-- END_TF_DOCS -->