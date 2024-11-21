resource "azurerm_virtual_network" "this" {
  count = var.create_network ? 1 : 0

  name                = "${var.cluster_name}-vnet"
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
  address_space       = [var.vnet_cidr]

  lifecycle {
    precondition {
      condition     = can(cidrhost(var.vnet_cidr, 0))
      error_message = "A valid IPv4 CIDR must be provided for 'vnet_cidr' variable."
    }
  }
}

resource "azurerm_subnet" "cluster" {
  #checkov:skip=CKV2_AZURE_31:AKS manages the NSGs appled to worker nodes - having one on the subnet would require either manual management or overly permissive rules that would defeat the purpose

  count = var.create_network ? 1 : 0

  name                                      = "cluster"
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = azurerm_virtual_network.this[0].name
  address_prefixes                          = [var.cluster_subnet_cidr]
  private_endpoint_network_policies_enabled = false
}

resource "azurerm_subnet_route_table_association" "cluster" {
  count = var.create_network ? 1 : 0

  subnet_id      = azurerm_subnet.cluster[0].id
  route_table_id = azurerm_route_table.cluster[0].id
}

resource "azurerm_route_table" "cluster" {
  count = var.create_network ? 1 : 0

  name                = "${var.cluster_name}-cluster"
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags
}

resource "azurerm_route" "cluster" {
  count = var.create_network ? 1 : 0

  name                = "local"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.cluster[0].name
  address_prefix      = var.vnet_cidr
  next_hop_type       = "VnetLocal"
}
