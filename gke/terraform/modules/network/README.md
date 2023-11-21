<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 5.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.nat](https://registry.terraform.io/providers/hashicorp/google/5.6.0/docs/resources/compute_address) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/5.6.0/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/5.6.0/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/5.6.0/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.cluster](https://registry.terraform.io/providers/hashicorp/google/5.6.0/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (network, subnetworks, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_network_cidr_range"></a> [network\_cidr\_range](#input\_network\_cidr\_range) | The CIDR for the cluster's network. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | n/a |
<!-- END_TF_DOCS -->