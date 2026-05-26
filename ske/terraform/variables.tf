################################################################################
# Required
################################################################################

variable "organization_id" {
  type        = string
  description = "STACKIT organization ID under which the network area and project are created."
}

variable "cluster_name" {
  type        = string
  description = "Name used for the SKE cluster, project, and as a prefix for network resources. Max 11 characters (STACKIT SKE limit)."

  validation {
    condition     = length(var.cluster_name) <= 11
    error_message = "cluster_name must be 11 characters or fewer (STACKIT SKE limit)."
  }
}

variable "owner_email" {
  type        = string
  description = "Owner email assigned to the STACKIT project."
}

################################################################################
# Region / network
################################################################################

variable "region" {
  type        = string
  default     = "eu01"
  description = "STACKIT region to deploy resources into."
}

variable "cluster_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "IPv4 CIDR for the cluster network."
}

variable "additional_sna_ranges" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "Additional IPv4 prefixes added to the STACKIT Network Area, alongside cluster_cidr. Commonly used for a VPN gateway range."
}

variable "transfer_network_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "IPv4 CIDR for the network area's transfer network."
}

variable "network_dns_servers" {
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "IPv4 nameservers configured on the cluster network."
}

################################################################################
# Cluster
################################################################################

variable "kubernetes_api_access_scope" {
  type        = string
  default     = "PUBLIC"
  description = "Control plane access scope. PUBLIC exposes the Kubernetes API to the internet; SNA restricts access to the STACKIT Network Area the cluster is bound to."
}

################################################################################
# Node pools
################################################################################

variable "worker_node_pool_min_size" {
  type        = number
  default     = 0
  description = "Minimum number of nodes for messaging and monitoring node pools."
}

variable "node_pool_max_size" {
  type        = number
  default     = 10
  description = "Maximum number of nodes for messaging and monitoring node pools."
}

variable "node_pool_volume_size" {
  type        = number
  default     = 50
  description = "Root volume size in GiB for each node pool. Default is sized for Solace Cloud broker workloads."
}

variable "node_pool_volume_type" {
  type        = string
  default     = "storage_premium_perf2"
  description = "STACKIT block-storage performance class for each node pool's root volume. Default is suitable for Solace Cloud broker workloads."
}

################################################################################
# Bastion
################################################################################

variable "create_bastion" {
  type        = bool
  default     = false
  description = "Whether to create a bastion host with a public IP."
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

variable "bastion_ssh_source_cidr" {
  type        = string
  default     = ""
  description = "Source CIDR allowed to SSH to the bastion (port 22). Required when create_bastion is true."
}

variable "bastion_icmp_source_cidr" {
  type        = string
  default     = ""
  description = "Source CIDR allowed to send ICMP echo (ping) to the bastion. Leave empty to omit the ICMP ingress rule entirely."
}
