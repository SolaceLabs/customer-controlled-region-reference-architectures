variable "cluster_name" {
  type        = string
  description = "Name of the SKE cluster. STACKIT limits cluster names to 11 characters."

  validation {
    condition     = length(var.cluster_name) <= 11
    error_message = "cluster_name must be 11 characters or fewer (StackIT SKE limit)."
  }
}

variable "project_id" {
  type        = string
  description = "STACKIT project ID where the cluster is created."
}

variable "network_id" {
  type        = string
  description = "STACKIT network ID that the cluster's nodes attach to."
}

variable "node_pools" {
  type        = any
  description = "List of node pool config objects to apply to the cluster. STACKIT requires node pools to be defined inline on stackit_ske_cluster; assemble the list at the calling layer (e.g. via broker-node-pool module outputs)."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version for the cluster. Maps to kubernetes_version_min on stackit_ske_cluster."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publicly from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "List of CIDRs allowed to reach the Kubernetes API via the extensions.acl block. When empty, no ACL is applied."
}

variable "dns_enabled" {
  type        = bool
  default     = false
  description = "When set to true, enables the externalDNS extension on the cluster."
}

variable "dns_zones" {
  type        = list(string)
  default     = []
  description = "DNS zones that externalDNS is allowed to manage records in. When empty, all zones are allowed."
}

variable "observability_enabled" {
  type        = bool
  default     = false
  description = "When set to true, enables the STACKIT Observability integration on the cluster."
}

variable "observability_instance_id" {
  type        = string
  default     = null
  description = "ID of the STACKIT Observability instance to send cluster telemetry to. Required when observability_enabled is true."
}

