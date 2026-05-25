variable "organization_id" {
  type        = string
  description = "STACKIT organization ID that owns the network area."
}

variable "project_id" {
  type        = string
  description = "STACKIT project ID where the project-scoped network is created."
}

variable "cluster_name" {
  type        = string
  description = "Name prefix for network resources. Produces cluster_name + '-sna' for the network area and cluster_name + '-network' for the network."
}

variable "region" {
  type        = string
  description = "STACKIT region used for the network area region binding (e.g. eu01)."
}

variable "cluster_cidr" {
  type        = string
  description = "IPv4 CIDR for the cluster network and the primary prefix in the network area."
}

variable "additional_sna_ranges" {
  type        = list(string)
  default     = []
  description = "Additional IPv4 prefixes added to the STACKIT Network Area, alongside cluster_cidr. Commonly used for a VPN gateway range."
}

variable "transfer_network_cidr" {
  type        = string
  description = "IPv4 CIDR for the network area's transfer network."
}

variable "network_dns_servers" {
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
  description = "IPv4 nameservers configured on the cluster network."
}
