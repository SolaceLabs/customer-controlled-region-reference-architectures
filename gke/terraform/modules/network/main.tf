resource "google_compute_network" "this" {
  #checkov:skip=CKV2_GCP_18:Firewall rules are auto-created by the cluster

  count = var.create_network ? 1 : 0

  name                    = "${var.cluster_name}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "cluster" {
  #checkov:skip=CKV_GCP_76:This is not requried, subnetwork is not cofigured to use ipv6
  #checkov:skip=CKV_GCP_26:Solace is not opinionated on the use of VPC flow logs

  count = var.create_network ? 1 : 0

  name          = "${var.cluster_name}-subnetwork"
  ip_cidr_range = var.network_cidr_range
  network       = google_compute_network.this[0].name

  private_ip_google_access = true

  lifecycle {
    ignore_changes = [secondary_ip_range] # these are automatically added by gke

    precondition {
      condition     = can(cidrhost(var.network_cidr_range, 0))
      error_message = "A valid IPv4 CIDR must be provided for 'network_cidr_range' variable."
    }
  }
}

resource "google_compute_router" "router" {
  count = var.create_network ? 1 : 0

  name    = "${var.cluster_name}-router"
  network = google_compute_network.this[0].id
}

resource "google_compute_address" "nat" {
  count = var.create_network ? 2 : 0

  name = "${var.cluster_name}-nat-ip-${count.index}"
}

resource "google_compute_router_nat" "nat" {
  count = var.create_network ? 1 : 0

  name   = "${var.cluster_name}-router-nat"
  router = google_compute_router.router[0].name

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat[*].self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.cluster[0].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}