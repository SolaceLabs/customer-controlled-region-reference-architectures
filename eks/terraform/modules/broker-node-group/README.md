<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.39.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.39.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.labels_tags](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.name_tag](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.resources_tags](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_autoscaling_group_tag.taints_tags](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/eks_node_group) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/5.39.0/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the EKS cluster. | `string` | n/a | yes |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | The desired size of the node groups. | `number` | `0` | no |
| <a name="input_node_group_labels"></a> [node\_group\_labels](#input\_node\_group\_labels) | Kubernetes labels added to worker nodes in the node groups. | `map(string)` | n/a | yes |
| <a name="input_node_group_max_size"></a> [node\_group\_max\_size](#input\_node\_group\_max\_size) | The maximum size of the node groups. | `number` | n/a | yes |
| <a name="input_node_group_min_size"></a> [node\_group\_min\_size](#input\_node\_group\_min\_size) | The minimum size of the node groups. | `number` | `0` | no |
| <a name="input_node_group_name_prefix"></a> [node\_group\_name\_prefix](#input\_node\_group\_name\_prefix) | The prefix for the node groups. | `string` | n/a | yes |
| <a name="input_node_group_resources_tags"></a> [node\_group\_resources\_tags](#input\_node\_group\_resources\_tags) | Resources tags added to the node groups as hints for the autoscaler. | `list(map(string))` | n/a | yes |
| <a name="input_node_group_taints"></a> [node\_group\_taints](#input\_node\_group\_taints) | Kubernetes taints added to worker nodes in the node groups. | `list(map(string))` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The security groups that will be attached to the worker nodes. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnets that the node groups will use - a node group is created in each subnet. | `list(string)` | n/a | yes |
| <a name="input_use_random_suffix_in_node_group_name"></a> [use\_random\_suffix\_in\_node\_group\_name](#input\_use\_random\_suffix\_in\_node\_group\_name) | Whether to use auto generated random suffix in node group name | `bool` | `true` | no |
| <a name="input_worker_node_instance_type"></a> [worker\_node\_instance\_type](#input\_worker\_node\_instance\_type) | The instance type of the worker nodes. | `string` | n/a | yes |
| <a name="input_worker_node_role_arn"></a> [worker\_node\_role\_arn](#input\_worker\_node\_role\_arn) | The ARN of the IAM role assigned to each worker node via an instance profile. | `string` | n/a | yes |
| <a name="input_worker_node_tags"></a> [worker\_node\_tags](#input\_worker\_node\_tags) | Tags that are added to worker nodes. | `map(string)` | `{}` | no |
| <a name="input_worker_node_volume_size"></a> [worker\_node\_volume\_size](#input\_worker\_node\_volume\_size) | The size of the worker node root disk. | `number` | n/a | yes |
| <a name="input_worker_node_volume_type"></a> [worker\_node\_volume\_type](#input\_worker\_node\_volume\_type) | The volume type of the worker node root disk. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_group_arns"></a> [node\_group\_arns](#output\_node\_group\_arns) | n/a |
<!-- END_TF_DOCS -->