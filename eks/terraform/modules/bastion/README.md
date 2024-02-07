<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.bastion_AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/instance) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/key_pair) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.bastion_egress](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.bastion_ssh](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.cluster_from_bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/resources/security_group_rule) | resource |
| [aws_ami.amazon-linux](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.bastion](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/5.35.0/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_public_access"></a> [bastion\_public\_access](#input\_bastion\_public\_access) | When set to true the bastion host is assigned a public IP and can be access from any of the networks provided in the 'bastion\_ssh\_authorized\_networks' parameter. | `bool` | `true` | no |
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | The ID of the cluster's security group. Used to provide access to the cluster API from the bastion host. | `string` | `null` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the bastion will reside. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the bastion will reside. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
<!-- END_TF_DOCS -->