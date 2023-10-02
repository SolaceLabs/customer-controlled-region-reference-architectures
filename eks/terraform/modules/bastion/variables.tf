variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "vpc_id" {
  type        = string
  default     = null
  description = "The ID of the VPC where the bastion will reside."
}

variable "subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet where the bastion will reside."
}

variable "create_bastion" {
  type        = bool
  default     = true
  description = "Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately."
}

variable "bastion_public_access" {
  type        = bool
  default     = true
  description = "When set to true the bastion host is assigned a public IP and can be access from any of the networks provided in the 'bastion_ssh_authorized_networks' parameter."
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

variable "cluster_security_group_id" {
  type        = string
  default     = null
  description = "The ID of the cluster's security group. Used to provide access to the cluster API from the bastion host."
}