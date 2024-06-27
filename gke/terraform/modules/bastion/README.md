<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 5.31.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.31.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.bastion](https://registry.terraform.io/providers/hashicorp/google/5.31.1/docs/resources/compute_firewall) | resource |
| [google_compute_instance.bastion](https://registry.terraform.io/providers/hashicorp/google/5.31.1/docs/resources/compute_instance) | resource |
| [google_service_account.bastion](https://registry.terraform.io/providers/hashicorp/google/5.31.1/docs/resources/service_account) | resource |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/5.31.1/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_ssh_authorized_networks"></a> [bastion\_ssh\_authorized\_networks](#input\_bastion\_ssh\_authorized\_networks) | The list of CIDRs that can access the SSH port (22) on the bastion host. | `list(string)` | `[]` | no |
| <a name="input_bastion_ssh_public_key"></a> [bastion\_ssh\_public\_key](#input\_bastion\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the bastion host for SSH access. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Labels that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately. | `bool` | `true` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | The name of the network where the bastion will reside. | `string` | `null` | no |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | The name of the subnetwork where the bastion will reside. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | n/a |
<!-- END_TF_DOCS -->