locals {
  zone_aware_naming = length(var.availability_zones) > 1

  node_pools = [
    for idx, zone in var.availability_zones : {
      name                    = local.zone_aware_naming ? "${var.pool_name_prefix}${idx + 1}" : var.pool_name_prefix
      availability_zones      = ["${var.region}-${zone}"]
      machine_type            = var.machine_type
      volume_size             = var.volume_size
      volume_type             = var.volume_type
      max_surge               = var.max_surge
      max_unavailable         = var.max_unavailable
      minimum                 = var.min_size
      maximum                 = var.max_size
      labels                  = var.node_pool_labels
      taints                  = var.node_pool_taints
      allow_system_components = var.allow_system_components
    }
  ]
}
