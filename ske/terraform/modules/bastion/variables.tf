variable "cluster_name" {
  type        = string
  description = "Cluster name. Used as a prefix for bastion resource names (e.g. cluster_name + '-bastion', cluster_name + '-bastion-sg', cluster_name + '-bastion-kp')."
}

variable "project_id" {
  type        = string
  description = "STACKIT project ID where the bastion is created."
}

variable "network_id" {
  type        = string
  description = "Network ID for the bastion's NIC."
}

variable "create_bastion" {
  type        = bool
  default     = false
  description = "Whether to create a bastion host. When false, no resources are created and outputs are null."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH public key string installed on the bastion. Required when create_bastion is true."
}

variable "bastion_image_id" {
  type        = string
  default     = ""
  description = "STACKIT image UUID for the bastion VM. Required when create_bastion is true. Find current Ubuntu UUIDs via `stackit image list --project-id <any-org-project>` filtered to distro=ubuntu."
}

variable "machine_type" {
  type        = string
  default     = "g2i.1"
  description = "STACKIT VM flavor for the bastion host."
}

variable "boot_volume_size" {
  type        = number
  default     = 16
  description = "Boot volume size in GiB for the bastion host."
}

variable "bastion_ssh_source_cidr" {
  type        = string
  default     = ""
  description = "Source CIDR allowed to SSH to the bastion (port 22). Required when create_bastion is true. STACKIT security group rules accept a single CIDR per rule; for multiple sources, extend the module."
}

variable "bastion_icmp_source_cidr" {
  type        = string
  default     = ""
  description = "Source CIDR allowed to send ICMP echo (ping) to the bastion. Leave empty to omit the ICMP ingress rule entirely."
}
