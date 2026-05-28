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
| [stackit_ske_cluster.this](https://registry.terraform.io/providers/stackitcloud/stackit/latest/docs/resources/ske_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the SKE cluster. STACKIT limits cluster names to 11 characters. | `string` | n/a | yes |
| <a name="input_dns_enabled"></a> [dns\_enabled](#input\_dns\_enabled) | When set to true, enables the externalDNS extension on the cluster. | `bool` | `false` | no |
| <a name="input_dns_zones"></a> [dns\_zones](#input\_dns\_zones) | DNS zones that externalDNS is allowed to manage records in. When empty, all zones are allowed. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | List of CIDRs allowed to reach the Kubernetes API via the extensions.acl block. When empty, no ACL is applied. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publicly from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version for the cluster. Maps to kubernetes\_version\_min on stackit\_ske\_cluster. | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | STACKIT network ID that the cluster's nodes attach to. | `string` | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List of node pool config objects to apply to the cluster. STACKIT requires node pools to be defined inline on stackit\_ske\_cluster; assemble the list at the calling layer (e.g. via broker-node-pool module outputs). | `any` | n/a | yes |
| <a name="input_observability_enabled"></a> [observability\_enabled](#input\_observability\_enabled) | When set to true, enables the STACKIT Observability integration on the cluster. | `bool` | `false` | no |
| <a name="input_observability_instance_id"></a> [observability\_instance\_id](#input\_observability\_instance\_id) | ID of the STACKIT Observability instance to send cluster telemetry to. Required when observability\_enabled is true. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | STACKIT project ID where the cluster is created. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | Terraform internal resource ID of the cluster, structured as project\_id,region,name. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the SKE cluster. |
| <a name="output_egress_address_ranges"></a> [egress\_address\_ranges](#output\_egress\_address\_ranges) | Outgoing network ranges (CIDR) of traffic originating from cluster workloads. |
| <a name="output_kubernetes_version_used"></a> [kubernetes\_version\_used](#output\_kubernetes\_version\_used) | Full kubernetes version currently used by the cluster. |
| <a name="output_pod_address_ranges"></a> [pod\_address\_ranges](#output\_pod\_address\_ranges) | Network ranges (CIDR) used by pods in the cluster. Auto-assigned by STACKIT from the CGNAT range 100.64.0.0/10. |
<!-- END_TF_DOCS -->