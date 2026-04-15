output "subnet_id" {
  value = var.create_network ? azurerm_subnet.cluster[0].id : null
}

output "secondary_subnet_id" {
  value = var.create_network && var.secondary_vnet_cidr != null ? azurerm_subnet.cluster_secondary[0].id : null
}

output "route_table_id" {
  value = var.create_network ? azurerm_route_table.cluster[0].id : null
}

output "virtual_network_name" {
  value = var.create_network ? azurerm_virtual_network.this[0].name : null
}
