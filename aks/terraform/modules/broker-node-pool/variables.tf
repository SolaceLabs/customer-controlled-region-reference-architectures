variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module."
}

variable "cluster_id" {
  type        = string
  description = "The ID of the cluster."
}

variable "node_pool_name" {
  type        = string
  description = "The name prefix of the node pools."
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones for the node pools - one pool is created in each zone."
}

variable "subnet_id" {
  type        = string
  description = "The subnet that will contain the worker nodes in each node pool."
}

variable "node_pool_max_size" {
  type        = string
  description = "The maximum worker node count for each node pool."
}

variable "worker_node_vm_size" {
  type        = string
  description = "The VM size used for the worker nodes in each node pool."
}

variable "worker_node_disk_size" {
  type        = string
  description = "The OS disk size (in GB) used for the worker nodes in each node pool."
}

variable "node_pool_labels" {
  type        = map(string)
  description = "Kubernetes labels added to worker nodes in the node pools."
}

variable "node_pool_taints" {
  type        = list(string)
  description = "Kubernetes taints added to worker nodes in the node pools."
}

variable "worker_node_max_pods" {
  type        = number
  description = "The maximum number of pods for the worker nodes in the node pools."
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version for the node pools."
}