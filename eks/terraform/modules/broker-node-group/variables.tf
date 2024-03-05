variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use for the node group."
}

variable "security_group_ids" {
  type        = list(string)
  description = "The security groups that will be attached to the worker nodes."
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnets that the node groups will use - a node group is created in each subnet."
}

variable "node_group_name_prefix" {
  type        = string
  description = "The prefix for the node groups."
}

variable "node_group_min_size" {
  type        = number
  description = "The minimum size of the node groups."
  default     = 0
}

variable "node_group_desired_size" {
  type        = number
  description = "The desired size of the node groups."
  default     = 0
}

variable "node_group_max_size" {
  type        = number
  description = "The maximum size of the node groups."
}

variable "node_group_labels" {
  type        = map(string)
  description = "Kubernetes labels added to worker nodes in the node groups."
}

variable "node_group_taints" {
  type        = list(map(string))
  description = "Kubernetes taints added to worker nodes in the node groups."
}

variable "node_group_resources_tags" {
  type        = list(map(string))
  description = "Resources tags added to the node groups as hints for the autoscaler."
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