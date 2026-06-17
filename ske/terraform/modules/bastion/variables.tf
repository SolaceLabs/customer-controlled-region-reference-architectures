variable "cluster_name" {
  type        = string
  description = "Cluster name. Used as a prefix for bastion resource names (e.g. cluster_name + '-bastion', cluster_name + '-bastion-sg')."
}

variable "project_id" {
  type        = string
  description = "STACKIT project ID where the bastion is created."
}

variable "network_id" {
  type        = string
  description = "Project-scoped network ID for the bastion's NIC."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = null
  description = "SSH public key installed on the bastion via a stackit_key_pair resource. When null, no key pair is created and access relies on user_data alone."
}

variable "user_data" {
  type        = string
  default     = null
  description = "Cloud-init user data passed to the bastion VM."
}

variable "bastion_image_id" {
  type        = string
  description = "STACKIT image UUID for the bastion VM."
}

variable "machine_type" {
  type        = string
  default     = "g2i.1"
  description = "STACKIT VM flavor for the bastion host."
}

variable "boot_volume_size" {
  type        = number
  default     = 20
  description = "Boot volume size in GiB for the bastion host."
}

variable "bastion_ssh_source_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Source CIDRs allowed to SSH to the bastion (port 22). One ingress rule is created per CIDR. Must be non-empty."

  validation {
    condition     = length(var.bastion_ssh_source_cidrs) > 0
    error_message = "At least one SSH source CIDR must be provided."
  }
}

variable "bastion_icmp_source_cidrs" {
  type        = list(string)
  default     = []
  description = "Source CIDRs allowed to send ICMP echo (ping) to the bastion. One ingress rule is created per CIDR. Leave empty to omit ICMP entirely."
}

variable "bastion_egress_cidrs" {
  type        = list(string)
  default     = []
  description = "Destination CIDRs the bastion is allowed to reach (egress). One egress rule is created per CIDR. Defaults to empty, which allows egress to any destination."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Labels merged into the module-default labels and applied to every taggable bastion resource. STACKIT label keys do not allow ':' — use a separator like '_' (e.g. solace_env)."
}

variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Map of resource labels to apply to all resources that support labelling."
}
