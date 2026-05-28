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

variable "bastion_ssh_public_key" {
  type        = string
  description = "SSH public key string installed on the bastion."
}

variable "bastion_image_id" {
  type        = string
  description = "STACKIT image UUID for the bastion VM. Find current Ubuntu UUIDs via `stackit image list --project-id <any-org-project>` filtered to distro=ubuntu."
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
  description = "Source CIDR allowed to SSH to the bastion (port 22). Must be non-empty when the bastion is created. STACKIT security group rules accept a single CIDR per rule; for multiple sources, extend the module."
}

variable "bastion_icmp_source_cidr" {
  type        = string
  default     = ""
  description = "Source CIDR allowed to send ICMP echo (ping) to the bastion. Leave empty to omit the ICMP ingress rule entirely."
}

variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Map of resource labels to apply to all resources that support labelling."
}
