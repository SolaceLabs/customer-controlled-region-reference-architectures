variable "pool_name_prefix" {
  type        = string
  description = "Pool name prefix. When length(availability_zones) > 1, rendered pool names are prefix + '1', prefix + '2', etc.; otherwise the prefix is used unchanged. Example: prefix 'prod1k' + zones ['1', '2'] becomes 'prod1k1', 'prod1k2'."
}

variable "region" {
  type        = string
  description = "StackIT region (e.g. eu01). Used to construct full zone names as region + '-' + zone (e.g. eu01-1)."
}

variable "availability_zones" {
  type        = list(string)
  description = "Zone suffixes. One node pool config object is produced per zone. Examples: ['1', '2'] for messaging, ['3'] for monitoring, ['m'] for metro / system."
}

variable "machine_type" {
  type        = string
  description = "StackIT VM flavor (e.g. m2i.2)."
}

variable "volume_size" {
  type        = number
  default     = 50
  description = "Root volume size in GiB for each node. Default is sized for Solace Cloud broker workloads."
}

variable "volume_type" {
  type        = string
  default     = "storage_premium_perf2"
  description = "STACKIT block-storage performance class for the root volume (e.g. storage_premium_perf2). Default is suitable for Solace Cloud broker workloads."
}

variable "min_size" {
  type        = number
  default     = 0
  description = "Per-pool autoscale minimum node count."
}

variable "max_size" {
  type        = number
  default     = 5
  description = "Per-pool autoscale maximum node count."
}

variable "max_surge" {
  type        = number
  default     = 1
  description = "Upgrade max_surge for the pool."
}

variable "max_unavailable" {
  type        = number
  default     = 1
  description = "Upgrade max_unavailable for the pool."
}

variable "node_pool_labels" {
  type        = map(string)
  default     = {}
  description = "Kubernetes labels applied to nodes in the pool."
}

variable "node_pool_taints" {
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default     = []
  description = "Kubernetes taints applied to nodes in the pool."
}

variable "allow_system_components" {
  type        = bool
  default     = false
  description = "StackIT-specific flag. Set to true only for the system pool that hosts cluster system workloads (CoreDNS, etc.)."
}
