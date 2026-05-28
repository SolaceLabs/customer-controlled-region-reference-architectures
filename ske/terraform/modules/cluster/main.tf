locals {
  acl_extension = length(var.kubernetes_api_authorized_networks) > 0 ? {
    enabled       = true
    allowed_cidrs = var.kubernetes_api_authorized_networks
  } : null

  dns_extension = var.dns_enabled ? {
    enabled = true
    zones   = var.dns_zones
  } : null

  observability_extension = var.observability_enabled ? {
    enabled     = true
    instance_id = var.observability_instance_id
  } : null

  cluster_extensions = merge(
    local.acl_extension == null ? {} : { acl = local.acl_extension },
    local.dns_extension == null ? {} : { dns = local.dns_extension },
    local.observability_extension == null ? {} : { observability = local.observability_extension },
  )
}

resource "stackit_ske_cluster" "this" {
  name                   = var.cluster_name
  project_id             = var.project_id
  kubernetes_version_min = var.kubernetes_version

  maintenance = {
    enable_kubernetes_version_updates    = false
    enable_machine_image_version_updates = false
    start                                = "02:00:00Z"
    end                                  = "04:00:00Z"
  }

  node_pools = var.node_pools

  network = {
    control_plane = {
      access_scope = var.kubernetes_api_public_access ? "PUBLIC" : "SNA"
    }
    id = var.network_id
  }

  extensions = length(local.cluster_extensions) > 0 ? local.cluster_extensions : null
}
