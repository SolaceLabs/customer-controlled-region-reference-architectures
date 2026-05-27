variable "organization_id" {
  type        = string
  description = "STACKIT organization ID that owns the network area."
}

variable "project_id" {
  type        = string
  description = "STACKIT project ID where the project-scoped network is created."
}

variable "name" {
  type        = string
  description = "Name prefix for network resources. Produces name + '-sna' for the network area and name + '-network' for the network."
}

variable "region" {
  type        = string
  description = "STACKIT region used for the network area region binding (e.g. eu01)."
}

variable "cluster_cidr" {
  type        = string
  description = "IPv4 CIDR for the cluster network and the primary prefix in the network area. Must not overlap with the CGNAT range (100.64.0.0/10)."
}

variable "additional_sna_ranges" {
  type        = list(string)
  default     = []
  description = "Additional IPv4 prefixes added to the STACKIT Network Area, alongside cluster_cidr. Commonly used for a VPN gateway range. Must not overlap with the CGNAT range (100.64.0.0/10)."
}

variable "transfer_network_cidr" {
  type        = string
  description = "IPv4 CIDR for the network area's transfer network. Must not overlap with the CGNAT range (100.64.0.0/10)."
}

variable "network_dns_servers" {
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "IPv4 nameservers configured on the cluster network."

  validation {
    condition     = length(var.network_dns_servers) > 0
    error_message = "At least one DNS server must be provided. Cluster nodes will fail to join without functional DNS."
  }
}

variable "resource_labels" {
  type        = map(string)
  description = "Map of resource labels to apply to all resources that support labelling."
  default     = {}
}
