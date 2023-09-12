resource "google_compute_network" "network" {
  name                    = "${var.cluster_name}-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "cluster" {
  name          = "${var.cluster_name}-subnetwork"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.network.name

  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "${var.cluster_name}-router"
  network = google_compute_network.network.id
}

resource "google_compute_address" "nat" {
  count = 2

  name = "${var.cluster_name}-nat-ip-${count.index}"
}

resource "google_compute_router_nat" "nat" {
  name   = "${var.cluster_name}-router-nat"
  router = google_compute_router.router.name

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.nat[*].self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.cluster.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}