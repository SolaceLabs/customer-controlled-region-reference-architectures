################################################################################
# Network
################################################################################

module "network" {
  source = "./modules/network"

  cluster_name   = var.cluster_name
  create_network = var.create_network

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  pod_spread_policy = var.pod_spread_policy
}

################################################################################
# Bastion
################################################################################

module "bastion" {
  source = "./modules/bastion"

  cluster_name = var.cluster_name

  create_bastion = var.create_bastion && var.create_network

  vpc_id    = var.create_network ? module.network.vpc_id : null
  subnet_id = var.create_network ? module.network.public_subnets[2] : null

  bastion_public_access           = var.bastion_public_access
  bastion_ssh_authorized_networks = var.bastion_ssh_authorized_networks
  bastion_ssh_public_key          = var.bastion_ssh_public_key
  cluster_security_group_id       = module.cluster.cluster_security_group_id
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  region       = var.region
  cluster_name = var.cluster_name

  vpc_id             = var.create_network ? module.network.vpc_id : var.vpc_id
  private_subnet_ids = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  kubernetes_version                 = var.kubernetes_version
  kubernetes_service_cidr            = var.kubernetes_service_cidr
  node_group_max_size                = var.node_group_max_size
  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.kubernetes_api_authorized_networks

  kubernetes_cluster_auth_mode  = var.kubernetes_cluster_auth_mode
  kubernetes_cluster_admin_arns = var.kubernetes_cluster_admin_arns

  pod_spread_policy = var.pod_spread_policy
}