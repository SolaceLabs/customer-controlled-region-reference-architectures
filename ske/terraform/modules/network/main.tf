resource "stackit_network_area" "this" {
  organization_id = var.organization_id
  name            = "${var.cluster_name}-sna"
}

resource "stackit_network_area_region" "this" {
  region          = var.region
  organization_id = var.organization_id
  network_area_id = stackit_network_area.this.network_area_id
  ipv4 = {
    transfer_network = var.transfer_network_cidr
    network_ranges   = concat([{ prefix = var.cluster_cidr }], [for range in var.additional_sna_ranges : { prefix = range }])
  }
}

resource "stackit_network" "this" {
  name             = "${var.cluster_name}-network"
  ipv4_prefix      = var.cluster_cidr
  project_id       = var.project_id
  ipv4_nameservers = var.network_dns_servers
}
