<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.42.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.nat](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/compute_address) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/compute_network) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.cluster](https://registry.terraform.io/providers/hashicorp/google/6.42.0/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_create_network"></a> [create\_network](#input\_create\_network) | When set to false, networking (network, subnetworks, etc) must be created externally. | `bool` | `true` | no |
| <a name="input_network_cidr_range"></a> [network\_cidr\_range](#input\_network\_cidr\_range) | The CIDR for the cluster's network. | `string` | `null` | no |
| <a name="input_secondary_cidr_range_messaging_pods"></a> [secondary\_cidr\_range\_messaging\_pods](#input\_secondary\_cidr\_range\_messaging\_pods) | The secondary CIDR range for the cluster's messaging node pools, if a separate range is desired. | `string` | `null` | no |
| <a name="input_secondary_cidr_range_pods"></a> [secondary\_cidr\_range\_pods](#input\_secondary\_cidr\_range\_pods) | The secondary CIDR range for the cluster's pods. If a separate CIDR range is provided for messaging pods, this range will be used for just the system (default) node pool. | `string` | `null` | no |
| <a name="input_secondary_cidr_range_services"></a> [secondary\_cidr\_range\_services](#input\_secondary\_cidr\_range\_services) | The secondary CIDR range for the cluster's services. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | n/a |
| <a name="output_secondary_cidr_range_name_pods"></a> [secondary\_cidr\_range\_name\_pods](#output\_secondary\_cidr\_range\_name\_pods) | n/a |
| <a name="output_secondary_range_name_messaging_pods"></a> [secondary\_range\_name\_messaging\_pods](#output\_secondary\_range\_name\_messaging\_pods) | n/a |
| <a name="output_secondary_range_name_services"></a> [secondary\_range\_name\_services](#output\_secondary\_range\_name\_services) | n/a |
| <a name="output_subnetwork_name"></a> [subnetwork\_name](#output\_subnetwork\_name) | n/a |
<!-- END_TF_DOCS -->