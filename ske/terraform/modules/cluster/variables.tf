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

variable "kubernetes_api_access_scope" {
  type        = string
  default     = "PUBLIC"
  description = "Control plane access scope. PUBLIC exposes the Kubernetes API to the internet; SNA restricts access to the STACKIT Network Area the cluster is bound to."

  validation {
    condition     = contains(["PUBLIC", "SNA"], var.kubernetes_api_access_scope)
    error_message = "kubernetes_api_access_scope must be PUBLIC or SNA."
  }
}
