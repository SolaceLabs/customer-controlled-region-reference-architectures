variable "region" {
  type        = string
  description = "The Azure region where this network will reside."
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module."
}

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (VNET, Subnets, etc) must be created externally."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group that will contain the network."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster."
}

variable "vnet_cidr" {
  type        = string
  default     = null
  description = "The CIDR of the cluster's VNET and cluster subnet."
}