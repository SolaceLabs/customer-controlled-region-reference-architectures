output "network_id" {
  value       = stackit_network.this.network_id
  description = "ID of the project-scoped network."
}

output "network_area_id" {
  value       = stackit_network_area.this.network_area_id
  description = "ID of the organization-scoped network area."
}
