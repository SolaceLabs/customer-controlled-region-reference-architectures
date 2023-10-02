variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "create_bastion" {
  type        = bool
  default     = true
  description = "Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately."
}

variable "network_name" {
  type        = string
  default     = null
  description = "The name of the network where the bastion will reside."
}

variable "subnetwork_name" {
  type        = string
  default     = null
  description = "The name of the subnetwork where the bastion will reside."
}

variable "bastion_ssh_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the SSH port (22) on the bastion host."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = ""
  description = "The public key that will be added to the authorized keys file on the bastion host for SSH access."
}