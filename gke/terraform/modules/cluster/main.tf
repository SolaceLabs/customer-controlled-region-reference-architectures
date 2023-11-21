locals {
  worker_node_oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]

  system_machine_type     = "n2-standard-2"
  prod1k_machine_type     = "n2-highmem-2"
  prod10k_machine_type    = "n2-highmem-4"
  prod100k_machine_type   = "n2-highmem-8"
  monitoring_machine_type = "n2-standard-2"
}

resource "google_service_account" "cluster" {
  account_id   = "${var.cluster_name}-nodes"
  display_name = "Service account for ${var.cluster_name} worker nodes"
}

################################################################################
# Cluster
################################################################################

data "google_container_engine_versions" "this" {
  location       = var.region
  version_prefix = "${var.kubernetes_version}."
}

resource "google_container_cluster" "cluster" {
  #checkov:skip=CKV_GCP_67:Rule no longer applicable - oldest master version possible is much newer than 1.12
  #checkov:skip=CKV_GCP_24:Pod Security Policy has been deprecated in Kubernetes
  #checkov:skip=CKV_GCP_12:Solace is not opinionated on the use of Network Policies in the cluster
  #checkov:skip=CKV_GCP_66:Binary authorization cannot be used as-is with Solace images
  #checkov:skip=CKV_GCP_65:Solace is not opinionated on how Kubernetes RBAC users are managed

  name               = var.cluster_name
  location           = var.region
  network            = var.network_name
  subnetwork         = var.subnetwork_name
  min_master_version = data.google_container_engine_versions.this.latest_master_version

  enable_intranode_visibility = true
  enable_l4_ilb_subsetting    = true

  initial_node_count       = 1
  remove_default_node_pool = true

  deletion_protection = false

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.secondary_cidr_range_pods
    services_ipv4_cidr_block = var.secondary_cidr_range_services
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = !var.kubernetes_api_public_access
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.kubernetes_api_authorized_networks
      content {
        cidr_block = cidr_blocks.value
      }
    }
  }

  node_config {
    #checkov:skip=CKV_GCP_69:GKE Metadata Server configuration not required, default node pool will be deleted
    #checkov:skip=CKV_GCP_21:Node label configuration not required, default node pool wil be deleted
    #checkov:skip=CKV_GCP_68:Secure boot onfiguration not required, default node pool wil be deleted

    service_account = google_service_account.cluster.email
  }

  release_channel {
    channel = "UNSPECIFIED"
  }
}

################################################################################
# Node Pools
################################################################################

data "google_compute_zones" "available" {

}

resource "google_container_node_pool" "system" {
  name     = "system"
  location = var.region
  cluster  = google_container_cluster.cluster.name

  max_pods_per_node = var.max_pods_per_node_system

  node_config {
    machine_type    = local.system_machine_type
    image_type      = "COS_CONTAINERD"
    oauth_scopes    = local.worker_node_oauth_scopes
    service_account = google_service_account.cluster.email

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

  node_count = 1
}

module "node_group_prod1k" {
  source = "../broker-node-pool"

  region             = var.region
  cluster_name       = google_container_cluster.cluster.name
  node_pool_name     = "${var.cluster_name}-prod1k"
  availability_zones = data.google_compute_zones.available.names

  worker_node_machine_type    = local.prod1k_machine_type
  worker_node_oauth_scopes    = local.worker_node_oauth_scopes
  worker_node_service_account = google_service_account.cluster.email

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod1k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod1k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod10k" {
  source = "../broker-node-pool"

  region             = var.region
  cluster_name       = google_container_cluster.cluster.name
  node_pool_name     = "${var.cluster_name}-prod10k"
  availability_zones = data.google_compute_zones.available.names

  worker_node_machine_type    = local.prod10k_machine_type
  worker_node_oauth_scopes    = local.worker_node_oauth_scopes
  worker_node_service_account = google_service_account.cluster.email

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod10k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod10k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod100k" {
  source = "../broker-node-pool"

  region             = var.region
  cluster_name       = google_container_cluster.cluster.name
  node_pool_name     = "${var.cluster_name}-prod100k"
  availability_zones = data.google_compute_zones.available.names

  worker_node_machine_type    = local.prod100k_machine_type
  worker_node_oauth_scopes    = local.worker_node_oauth_scopes
  worker_node_service_account = google_service_account.cluster.email

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod100k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod100k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_monitoring" {
  source = "../broker-node-pool"

  region             = var.region
  cluster_name       = google_container_cluster.cluster.name
  node_pool_name     = "${var.cluster_name}-monitoring"
  availability_zones = data.google_compute_zones.available.names

  worker_node_machine_type    = local.monitoring_machine_type
  worker_node_oauth_scopes    = local.worker_node_oauth_scopes
  worker_node_service_account = google_service_account.cluster.email

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType = "monitoring"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "monitoring"
      effect = "NO_EXECUTE"
    }
  ]
}