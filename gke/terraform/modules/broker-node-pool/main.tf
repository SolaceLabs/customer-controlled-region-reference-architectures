resource "google_container_node_pool" "this" {
  name              = var.node_pool_name
  location          = var.region
  cluster           = var.cluster_name
  max_pods_per_node = var.max_pods_per_node
  node_locations    = var.availability_zones

  network_config {
    pod_range = var.secondary_range_name
  }

  node_config {
    machine_type    = var.worker_node_machine_type
    image_type      = "UBUNTU_CONTAINERD" #checkov:skip=CKV_GCP_22:Ubuntu is required for XFS support
    oauth_scopes    = var.worker_node_oauth_scopes
    service_account = var.worker_node_service_account
    resource_labels = var.common_labels

    labels = var.node_pool_labels

    dynamic "taint" {
      for_each = var.node_pool_taints
      content {
        key    = taint.value["key"]
        value  = taint.value["value"]
        effect = taint.value["effect"]
      }
    }

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

  autoscaling {
    location_policy = "BALANCED"
    min_node_count  = 0
    max_node_count  = var.node_pool_max_size
  }
}