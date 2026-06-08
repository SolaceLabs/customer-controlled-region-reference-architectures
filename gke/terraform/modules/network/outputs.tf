output "network_name" {
  value = var.create_network ? google_compute_network.this[0].name : null
}

output "network_id" {
  value = var.create_network ? google_compute_network.this[0].id : null
}

output "subnetwork_name" {
  value = var.create_network ? google_compute_subnetwork.cluster[0].name : null
}

output "database_subnetwork_name" {
  value = var.create_network && var.database_network_cidr_range != null && var.database_subnetwork_cidr != null ? google_compute_subnetwork.database[0].name : null
}

output "secondary_cidr_range_name_pods" {
  value = var.create_network ? local.secondary_cidr_range_name_pods : null
}

output "secondary_range_name_messaging_pods" {
  value = var.create_network && var.secondary_cidr_range_messaging_pods != null ? local.secondary_range_name_messaging_pods : null
}

output "secondary_range_name_services" {
  value = var.create_network && var.secondary_cidr_range_services != null ? local.secondary_range_name_services : null
}