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
}

variable "common_labels" {
  type        = map(string)
  default     = {}
  description = "Labels that are added to all resources created by this module."
}

################################################################################
# Network
################################################################################

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (network, subnetworks, etc) must be created externally."
}

variable "network_cidr_range" {
  type        = string
  default     = ""
  description = "The CIDR for the cluster's network. Worker nodes, load balancers, and other infrastructure is assigned an IP address from this range."
}

variable "secondary_cidr_range_default_pods" {
  type        = string
  description = "The secondary CIDR for the cluster's default node pool."
}

variable "secondary_cidr_range_messaging_pods" {
  type        = string
  description = "The secondary CIDR for the cluster's messaging node pools."
}

variable "secondary_cidr_range_services" {
  type        = string
  description = "The secondary CIDR for the cluster's services."
}

variable "network_name" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the network name must be provided."
}

variable "subnetwork_name" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the subnetwork name must be provided."
}

variable "secondary_range_name_default_pods" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the name of the seconary CIDR range for the cluster's default node pool must be provided."
}

variable "secondary_range_name_messaging_pods" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the name of the seconary CIDR range for the cluster's messaging node pools must be provided."
}

variable "secondary_range_name_services" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the name of the seconary CIDR range for the cluster's services must be provided."
}

################################################################################
# Bastion
################################################################################

variable "create_bastion" {
  type        = bool
  default     = true
  description = "Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately."
}

variable "bastion_ssh_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the SSH port (22) on the bastion host."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = ""
  description = "The public key that will be added to the authorized keys file on the bastion host for SSH access."
}

################################################################################
# Cluster
################################################################################

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The CIDR used to assign IPs to the Kubernetes API endpoints. This range must be unique within the VPC."
  default     = "172.16.0.32/28"
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