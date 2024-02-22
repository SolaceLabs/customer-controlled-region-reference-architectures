variable "region" {
  type        = string
  description = "The AWS region where this cluster will reside."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the cluster will reside."
}

variable "cluster_subnet_ids" {
  type        = list(string)
  default     = null
  description = "The IDs of the subnets where the cluster's private ENIs will reside. If not provided, IDs in private_subnet_ids will be used."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The IDs of the private subnets where the worker nodes will reside."
}

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "kubernetes_service_cidr" {
  type        = string
  default     = null
  description = "The CIDR used to assign IPs to kubernetes services, internal to the cluster."
}

variable "node_group_max_size" {
  type        = number
  default     = 10
  description = "The maximum size for the broker node groups in the cluster."
}

variable "broker_worker_node_arch" {
  type        = string
  default     = "x86_64"
  description = "The CPU architecture to use for the broker worker nodes, must be either 'x86_64' or 'arm64'."
  validation {
    condition     = var.broker_worker_node_arch == "x86_64" || var.broker_worker_node_arch == "arm64"
    error_message = "The broker_worker_node_arch value must be either 'x86_64' or 'arm64'."
  }
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

variable "pod_spread_policy" {
  type        = string
  default     = "full"
  description = "This controls which AZs host node groups for the primary, backup, and monitor node pools as well as which AZs will host the ENIs for the NLBs that front each event broker service. See the readme for more details."

  validation {
    condition     = var.pod_spread_policy == "full" || var.pod_spread_policy == "fixed"
    error_message = "The pod_spread_policy value must be either 'full' or 'fixed'."
  }
}

variable "kubernetes_cluster_access_identities" {
  type        = bool
  default     = false
  description = "When set to true, the cluster's access configuration is set to 'API'."
}

variable "kubernetes_cluster_admin_arns" {
  type        = list(string)
  default     = []
  description = "When kubernetes_cluster_access_identities is set to true, user or role ARNs can be provided that will be given the AmazonEKSClusterAdminPolicy."
}