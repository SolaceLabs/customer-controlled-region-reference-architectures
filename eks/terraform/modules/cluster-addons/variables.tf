variable "region" {
  type        = string
  description = "The AWS region where this cluster will reside."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster."
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module, in the cases where this cannot be accomplished with 'default_tags' on the AWS provider."
}

variable "default_node_group_arn" {
  type        = string
  description = "The ARN of the default node group. Some add-ons require this to be created before they can be created."
}

variable "addon_version_ebs_csi" {
  type        = string
  default     = null
  description = "The version of the ebs csi add-on to to install."
}

variable "addon_version_vpc_cni" {
  type        = string
  default     = null
  description = "The version of the vpc cni add-on to install."
}

variable "addon_version_core_dns" {
  type        = string
  default     = null
  description = "The version of core-dns add-on to install."
}

variable "addon_version_kube_proxy" {
  type        = string
  default     = null
  description = "The version of the kube-proxy add-on to install."
}

variable "addon_version_pod_identity" {
  type        = string
  default     = null
  description = "The version of the pod identity add-on to install."
}