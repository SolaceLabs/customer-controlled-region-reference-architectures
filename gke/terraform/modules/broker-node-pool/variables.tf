variable "region" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "node_pool_name" {
  type        = string
  description = "The name prefix the node pool."
}

variable "availability_zones" {
  type        = list(string)
  description = "The availability zones for the node pool."
}

variable "worker_node_machine_type" {
  type        = string
  description = "The machine type used for the worker nodes in this node pool."
}

variable "worker_node_oauth_scopes" {
  type        = list(string)
  description = "The OAuth scopes that will be assigned to the worker nodes in this node pool."
}

variable "worker_node_service_account" {
  type        = string
  description = "The service account that will be assigned to the worker nodes in this node pool."
}

variable "node_pool_labels" {
  type        = map(string)
  description = "Kubernetes labels added to worker nodes in the node pool."
}

variable "node_pool_taints" {
  type        = list(map(string))
  description = "Kubernetes taints added to worker nodes in the node pool."
}

variable "max_pods_per_node" {
  type        = number
  description = "The maximum number of pods per worker node for the node pool."
}

variable "node_pool_max_size" {
  type        = string
  description = "The maximum number of worker nodes for the node pool."
}