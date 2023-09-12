output "subnet_id" {
  value = var.create_network ? azurerm_subnet.cluster[0].id : null
}

output "route_table_id" {
  value = var.create_network ? azurerm_route_table.cluster[0].id : null
}