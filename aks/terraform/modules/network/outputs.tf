output "subnet_id" {
  value = var.create_network ? azurerm_subnet.cluster[0].id : null
}

output "database_subnet_id" {
  value = var.create_network && var.database_vnet_cidr != null ? azurerm_subnet.database[0].id : null
}

output "route_table_id" {
  value = var.create_network ? azurerm_route_table.cluster[0].id : null
}

output "virtual_network_id" {
  value = var.create_network ? azurerm_virtual_network.this[0].id : null
}
