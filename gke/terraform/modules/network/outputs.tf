output "network_name" {
  value = var.create_network ? google_compute_network.this[0].name : null
}

output "subnetwork_name" {
  value = var.create_network ? google_compute_subnetwork.cluster[0].name : null
}

output "secondary_range_name_default_pods" {
  value = var.create_network ? local.default_pods_secondary_range_name : null
}

output "secondary_range_name_messaging_pods" {
  value = var.create_network ? local.messaging_pods_secondary_range_name : null
}

output "secondary_range_name_services" {
  value = var.create_network ? local.services_secondary_range_name : null
}