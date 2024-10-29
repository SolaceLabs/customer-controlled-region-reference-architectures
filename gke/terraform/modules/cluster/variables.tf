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
    condition     = length(var.cluster_name) < 25
    error_message = "Cluster name must be less than 25 characters to satisfy google_service_account length restriction."
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

variable "secondary_cidr_range_pods" {
  type        = string
  description = "The secondary CIDR for the cluster's pods."
}

variable "secondary_cidr_range_services" {
  type        = string
  description = "The secondary CIDR for the cluster's services."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The CIDR used to assign IPs to the Kubernetes API endpoints."
}

variable "max_pods_per_node_system" {
  type        = number
  default     = 16
  description = "The maximum number of pods per worker node for the system node pool."
}

variable "max_pods_per_node_messaging" {
  type        = number
  default     = 8
  description = "The maximum number of pods per worker node for the messaging node pools."
}

variable "node_pool_max_size" {
  type        = string
  default     = 20
  description = "The maximum number of worker nodes for the messaging node pools."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publically from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default)."
}