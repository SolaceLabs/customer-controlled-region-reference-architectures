locals {
  worker_node_oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

resource "google_container_node_pool" "this" {
  name              = var.node_pool_name
  location          = var.region
  cluster           = var.cluster_name
  max_pods_per_node = var.max_pods_per_node
  node_locations    = var.availability_zones
  version           = var.kubernetes_version

  network_config {
    enable_private_nodes = true
  }

  node_config {
    machine_type    = var.worker_node_machine_type
    image_type      = "COS_CONTAINERD"
    oauth_scopes    = local.worker_node_oauth_scopes
    service_account = var.worker_node_service_account
    resource_labels = var.common_labels

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    #checkov:skip=CKV_GCP_10:Auto-upgrade disabled - Solace recommends that clusters be upgraded manually
    auto_upgrade = false
    auto_repair  = true
  }

  node_count = var.node_pool_size
}