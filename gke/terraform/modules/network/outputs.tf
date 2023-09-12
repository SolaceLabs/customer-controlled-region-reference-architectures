output "network_name" {
  value = var.create_network ? google_compute_network.this[0].name : null
}

output "subnetwork_name" {
  value = var.create_network ? google_compute_subnetwork.cluster[0].name : null
}