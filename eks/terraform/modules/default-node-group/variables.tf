variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use."
}

variable "worker_node_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to worker nodes."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The security groups that will be attached to the worker nodes."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets that the node group will use."
}

variable "node_group_name" {
  type        = string
  description = "The name the node group."
}

variable "node_group_desired_size" {
  type        = number
  description = "The desired size of the node group."
}

variable "worker_node_volume_size" {
  type        = number
  description = "The size of the worker node root disk."
}

variable "worker_node_volume_type" {
  type        = string
  description = "The volume type of the worker node root disk."
}

variable "worker_node_role_arn" {
  type        = string
  description = "The ARN of the IAM role assigned to each worker node via an instance profile."
}

variable "worker_node_instance_type" {
  type        = string
  description = "The instance type of the worker nodes."
}

variable "worker_node_ami_version" {
  type        = string
  description = "Value of the the AMI to use for the worker nodes."
}