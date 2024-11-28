variable "project" {
  type        = string
  description = "The GCP project that the cluster will reside in."
}

variable "region" {
  type        = string
  description = "The GCP region that the cluster will reside in."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."

  validation {
    condition     = length(var.cluster_name) <= 30
    error_message = "Cluster name must be30 characters or less to satisfy google_service_account length restriction."
  }
}

variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Labels that are added to all resources created by this module."
}

variable "network_name" {
  type        = string
  description = "The name of the network where the cluster will reside."
}

variable "subnetwork_name" {
  type        = string
  description = "The name of the subnetwork where the cluster will reside."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "secondary_range_name_services" {
  type        = string
  description = "The name of the secondary CIDR range for the cluster's services."
}

variable "secondary_range_name_pods" {
  type        = string
  description = "The name of the secondary CIDR range for the cluster's node pools. If a separate CIDR range is provided for messaging pods, this range will be used for just the system (default) node pool."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The CIDR used to assign IPs to the Kubernetes API endpoints."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publicly from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default)."
}