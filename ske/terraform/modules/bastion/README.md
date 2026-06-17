# bastion

An SSH jump host into a STACKIT region. Provisions a single VM on the project network,
attaches a public IP, and locks SSH ingress to an operator-supplied CIDR allow-list.

SSH access is configured via STACKIT's native `stackit_key_pair` resource (pass a single
public key via `bastion_ssh_public_key`). For additional hardening or multi-key setups,
pass a cloud-init payload via `user_data` — the module forwards it to the VM as-is.

## Finding a bastion image UUID

`bastion_image_id` must be provided when deploying through the root template (the project
is created in the same apply, so the image cannot be auto-resolved at plan time).

List available Ubuntu images from any existing project in your organization:

```bash
stackit image list --project-id <any-existing-project-id> | grep -E "Ubuntu 22\.04 +"
```

The `Ubuntu 22.04` (x86\_64) row shows the UUID to use. Example for eu01:
`3ad2867e-695b-4ee6-9502-b563013413d4`
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
| [stackit_key_pair.bastion](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/key_pair) | resource |
| [stackit_network_interface.bastion_nic](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/network_interface) | resource |
| [stackit_public_ip.bastion_public_ip](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/public_ip) | resource |
| [stackit_security_group.bastion_sg](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group) | resource |
| [stackit_security_group_rule.egress](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_security_group_rule.icmp](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_security_group_rule.ssh](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/security_group_rule) | resource |
| [stackit_server.bastion](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/server) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bastion_egress_cidrs"></a> [bastion\_egress\_cidrs](#input\_bastion\_egress\_cidrs) | Destination CIDRs the bastion is allowed to reach (egress). One egress rule is created per CIDR. Defaults to empty, which allows egress to any destination. | `list(string)` | `[]` | no |
| <a name="input_bastion_icmp_source_cidrs"></a> [bastion\_icmp\_source\_cidrs](#input\_bastion\_icmp\_source\_cidrs) | Source CIDRs allowed to send ICMP echo (ping) to the bastion. One ingress rule is created per CIDR. Leave empty to omit ICMP entirely. | `list(string)` | `[]` | no |
| <a name="input_bastion_image_id"></a> [bastion\_image\_id](#input\_bastion\_image\_id) | STACKIT image UUID for the bastion VM. | `string` | n/a | yes |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | SSH public key installed on the bastion via a stackit\_key\_pair resource. When null, no key pair is created and access relies on user\_data alone. | `string` | `null` | no |
| <a name="input_bastion_ssh_source_cidrs"></a> [bastion\_ssh\_source\_cidrs](#input\_bastion\_ssh\_source\_cidrs) | Source CIDRs allowed to SSH to the bastion (port 22). One ingress rule is created per CIDR. Must be non-empty. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_boot_volume_size"></a> [boot\_volume\_size](#input\_boot\_volume\_size) | Boot volume size in GiB for the bastion host. | `number` | `20` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name. Used as a prefix for bastion resource names (e.g. cluster\_name + '-bastion', cluster\_name + '-bastion-sg'). | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Map of resource labels to apply to all resources that support labelling. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | STACKIT VM flavor for the bastion host. | `string` | `"g2i.1"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Project-scoped network ID for the bastion's NIC. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID where the bastion is created. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Labels merged into the module-default labels and applied to every taggable bastion resource. STACKIT label keys do not allow ':' — use a separator like '\_' (e.g. solace\_env). | `map(string)` | `{}` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Cloud-init user data passed to the bastion VM. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_instance_id"></a> [bastion\_instance\_id](#output\_bastion\_instance\_id) | The bastion server's STACKIT server ID. |
| <a name="output_bastion_private_ip"></a> [bastion\_private\_ip](#output\_bastion\_private\_ip) | The bastion host's private IP address on the cluster network. |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | The bastion host's public IP address. |
| <a name="output_bastion_security_group_id"></a> [bastion\_security\_group\_id](#output\_bastion\_security\_group\_id) | ID of the bastion's security group. |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | The bastion host's SSH username. |
<!-- END_TF_DOCS -->