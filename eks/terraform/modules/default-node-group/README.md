<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.77.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.77.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group_tag.name](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/autoscaling_group_tag) | resource |
| [aws_eks_node_group.this](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/eks_node_group) | resource |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/5.77.0/docs/resources/launch_template) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version to use. | `string` | n/a | yes |
| <a name="input_node_group_desired_size"></a> [node\_group\_desired\_size](#input\_node\_group\_desired\_size) | The desired size of the node group. | `number` | n/a | yes |
| <a name="input_node_group_name"></a> [node\_group\_name](#input\_node\_group\_name) | The name the node group. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The security groups that will be attached to the worker nodes. | `list(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | The subnets that the node group will use. | `list(string)` | n/a | yes |
| <a name="input_worker_node_ami_version"></a> [worker\_node\_ami\_version](#input\_worker\_node\_ami\_version) | Value of the the AMI to use for the worker nodes. | `string` | n/a | yes |
| <a name="input_worker_node_instance_type"></a> [worker\_node\_instance\_type](#input\_worker\_node\_instance\_type) | The instance type of the worker nodes. | `string` | n/a | yes |
| <a name="input_worker_node_role_arn"></a> [worker\_node\_role\_arn](#input\_worker\_node\_role\_arn) | The ARN of the IAM role assigned to each worker node via an instance profile. | `string` | n/a | yes |
| <a name="input_worker_node_tags"></a> [worker\_node\_tags](#input\_worker\_node\_tags) | Tags that are added to worker nodes. | `map(string)` | `{}` | no |
| <a name="input_worker_node_volume_size"></a> [worker\_node\_volume\_size](#input\_worker\_node\_volume\_size) | The size of the worker node root disk. | `number` | n/a | yes |
| <a name="input_worker_node_volume_type"></a> [worker\_node\_volume\_type](#input\_worker\_node\_volume\_type) | The volume type of the worker node root disk. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_group_arn"></a> [node\_group\_arn](#output\_node\_group\_arn) | n/a |
<!-- END_TF_DOCS -->