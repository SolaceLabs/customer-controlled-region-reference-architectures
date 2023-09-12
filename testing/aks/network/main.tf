locals {
  cidr = "10.10.0.0/24"
}

resource "azurerm_resource_group" "network" {
  name     = "${var.cluster_name}-network"
  location = var.region
}

resource "azurerm_virtual_network" "cluster" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = [local.cidr]
}

resource "azurerm_subnet" "cluster" {
  name                                      = "cluster"
  resource_group_name                       = azurerm_resource_group.network.name
  virtual_network_name                      = azurerm_virtual_network.cluster.name
  address_prefixes                          = [local.cidr]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet_route_table_association" "cluster" {
  subnet_id      = azurerm_subnet.cluster.id
  route_table_id = azurerm_route_table.cluster.id
}

resource "azurerm_route_table" "cluster" {
  name                = "${var.cluster_name}-cluster"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
}

resource "azurerm_route" "cluster" {
  name                = "local"
  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.cluster.name
  address_prefix      = local.cidr
  next_hop_type       = "VnetLocal"
}