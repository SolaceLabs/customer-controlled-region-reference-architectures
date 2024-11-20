################################################################################
# Network
################################################################################

module "network" {
  source = "./modules/network"

  cluster_name = var.cluster_name

  create_network     = var.create_network
  network_cidr_range = var.network_cidr_range

  secondary_cidr_range_services       = var.secondary_cidr_range_services
  secondary_cidr_range_pods           = var.secondary_cidr_range_pods
  secondary_cidr_range_messaging_pods = var.secondary_cidr_range_messaging_pods
}

################################################################################
# Bastion
################################################################################

module "bastion" {
  source = "./modules/bastion"

  cluster_name = var.cluster_name

  create_bastion                  = var.create_bastion
  bastion_ssh_authorized_networks = var.bastion_ssh_authorized_networks
  bastion_ssh_public_key          = var.bastion_ssh_public_key

  network_name    = var.create_network ? module.network.network_name : var.network_name
  subnetwork_name = var.create_network ? module.network.subnetwork_name : var.subnetwork_name
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  project       = var.project
  region        = var.region
  cluster_name  = var.cluster_name
  common_labels = var.common_labels

  kubernetes_version = var.kubernetes_version

  master_ipv4_cidr_block = var.master_ipv4_cidr_block

  max_pods_per_node_system    = var.max_pods_per_node_system
  max_pods_per_node_messaging = var.max_pods_per_node_messaging
  node_pool_max_size          = var.node_pool_max_size

  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.create_bastion && var.create_network ? concat(var.kubernetes_api_authorized_networks, [var.network_cidr_range]) : var.kubernetes_api_authorized_networks

  network_name    = var.create_network ? module.network.network_name : var.network_name
  subnetwork_name = var.create_network ? module.network.subnetwork_name : var.subnetwork_name

  secondary_range_name_services       = var.create_network ? module.network.secondary_range_name_services : var.secondary_range_name_services
  secondary_range_name_pods           = var.create_network ? module.network.secondary_cidr_range_name_pods : var.secondary_range_name_pods
  secondary_range_name_messaging_pods = var.create_network ? module.network.secondary_range_name_messaging_pods : var.secondary_range_name_messaging_pods
}