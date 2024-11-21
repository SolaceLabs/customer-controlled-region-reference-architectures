resource "azurerm_resource_group" "cluster" {
  name     = "${var.cluster_name}-cluster"
  location = var.region
  tags     = var.common_tags
}

################################################################################
# Network
################################################################################

module "network" {
  source = "./modules/network"

  create_network = var.create_network

  resource_group_name = azurerm_resource_group.cluster.name
  region              = azurerm_resource_group.cluster.location
  common_tags         = var.common_tags
  cluster_name        = var.cluster_name

  vnet_cidr           = var.vnet_cidr
  cluster_subnet_cidr = var.vnet_cidr
}

################################################################################
# Bastion
################################################################################

module "bastion" {
  source = "./modules/bastion"

  create_bastion = var.create_bastion

  resource_group_name = azurerm_resource_group.cluster.name
  region              = azurerm_resource_group.cluster.location
  common_tags         = var.common_tags
  cluster_name        = var.cluster_name

  subnet_id = var.create_network ? module.network.subnet_id : var.subnet_id

  bastion_ssh_authorized_networks = var.bastion_ssh_authorized_networks
  bastion_ssh_public_key          = var.bastion_ssh_public_key
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  resource_group_name = azurerm_resource_group.cluster.name
  region              = azurerm_resource_group.cluster.location
  common_tags         = var.common_tags
  cluster_name        = var.cluster_name

  subnet_id      = var.create_network ? module.network.subnet_id : var.subnet_id
  route_table_id = var.create_network ? module.network.route_table_id : var.route_table_id

  kubernetes_version = var.kubernetes_version

  kubernetes_service_cidr   = var.kubernetes_service_cidr
  kubernetes_dns_service_ip = var.kubernetes_dns_service_ip
  kubernetes_pod_cidr       = var.kubernetes_pod_cidr

  node_pool_max_size = var.node_pool_max_size

  outbound_ip_count        = var.outbound_ip_count
  outbound_ports_allocated = var.outbound_ports_allocated

  worker_node_ssh_public_key = var.worker_node_ssh_public_key

  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.kubernetes_api_authorized_networks

  local_account_disabled          = var.local_account_disabled
  kubernetes_cluster_admin_groups = var.kubernetes_cluster_admin_groups
  kubernetes_cluster_admin_users  = var.kubernetes_cluster_admin_users
}