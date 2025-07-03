resource "google_service_account" "cluster" {
  account_id   = var.cluster_name
  display_name = "Service account for ${var.cluster_name} worker nodes"
}

resource "google_project_iam_member" "cluster_service_account_node_service_account" {
  project = google_service_account.cluster.project
  role    = "roles/container.defaultNodeServiceAccount"
  member  = google_service_account.cluster.member
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

  name       = var.cluster_name
  location   = var.region
  network    = var.network_name
  subnetwork = var.subnetwork_name

  min_master_version = data.google_container_engine_versions.this.latest_master_version

  resource_labels = var.common_labels

  enable_intranode_visibility = true
  enable_l4_ilb_subsetting    = true

  initial_node_count        = 1
  default_max_pods_per_node = 16
  remove_default_node_pool  = true

  deletion_protection = false

  networking_mode = "VPC_NATIVE"

  monitoring_config {
    managed_prometheus {
      enabled = false
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = var.secondary_range_name_pods
    services_secondary_range_name = var.secondary_range_name_services
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
    resource_labels = var.common_labels
  }

  release_channel {
    channel = "UNSPECIFIED"
  }

  lifecycle {
    ignore_changes = [min_master_version]
  }
}