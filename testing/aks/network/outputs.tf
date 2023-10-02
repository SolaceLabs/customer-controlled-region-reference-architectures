output "subnet_id" {
  value = azurerm_subnet.cluster.id
}

output "route_table_id" {
  value = azurerm_route_table.cluster.id
}