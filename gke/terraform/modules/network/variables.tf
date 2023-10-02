variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (network, subnetworks, etc) must be created externally."
}

variable "network_cidr_range" {
  type        = string
  default     = null
  description = "The CIDR for the cluster's network."
}