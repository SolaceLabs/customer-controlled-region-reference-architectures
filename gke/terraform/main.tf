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

  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.create_bastion && var.create_network ? concat(var.kubernetes_api_authorized_networks, [var.network_cidr_range]) : var.kubernetes_api_authorized_networks

  network_name    = var.create_network ? module.network.network_name : var.network_name
  subnetwork_name = var.create_network ? module.network.subnetwork_name : var.subnetwork_name

  secondary_range_name_services = var.create_network ? module.network.secondary_range_name_services : var.secondary_range_name_services
  secondary_range_name_pods     = var.create_network ? module.network.secondary_cidr_range_name_pods : var.secondary_range_name_pods
}

################################################################################
# Node Pools
################################################################################

locals {
  system_machine_type     = "n2-standard-2"
  prod1k_machine_type     = "n2-highmem-2"
  prod10k_machine_type    = "n2-highmem-4"
  prod100k_machine_type   = "n2-highmem-8"
  monitoring_machine_type = "e2-standard-2"
}

data "google_compute_zones" "available" {}

module "node_pool_system" {
  source = "./modules/system-node-pool"

  region             = var.region
  cluster_name       = module.cluster.cluster_name
  common_labels      = var.common_labels
  node_pool_name     = "system"
  kubernetes_version = module.cluster.master_version
  availability_zones = data.google_compute_zones.available.names

  worker_node_machine_type    = local.system_machine_type
  worker_node_service_account = module.cluster.worker_node_service_account

  max_pods_per_node = var.max_pods_per_node_system
  node_pool_size    = 1
}

module "node_pool_prod1k" {
  source = "./modules/broker-node-pool"

  region             = var.region
  cluster_name       = module.cluster.cluster_name
  common_labels      = var.common_labels
  node_pool_name     = "prod1k"
  availability_zones = data.google_compute_zones.available.names
  kubernetes_version = module.cluster.master_version

  secondary_range_name = var.create_network ? module.network.secondary_range_name_messaging_pods : var.secondary_range_name_messaging_pods

  worker_node_machine_type    = local.prod1k_machine_type
  worker_node_service_account = module.cluster.worker_node_service_account

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod1k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod1k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_pool_prod10k" {
  source = "./modules/broker-node-pool"

  region             = var.region
  cluster_name       = module.cluster.cluster_name
  common_labels      = var.common_labels
  node_pool_name     = "prod10k"
  availability_zones = data.google_compute_zones.available.names
  kubernetes_version = module.cluster.master_version

  secondary_range_name = var.create_network ? module.network.secondary_range_name_messaging_pods : var.secondary_range_name_messaging_pods

  worker_node_machine_type    = local.prod10k_machine_type
  worker_node_service_account = module.cluster.worker_node_service_account

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod10k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod10k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_pool_prod100k" {
  source = "./modules/broker-node-pool"

  region             = var.region
  cluster_name       = module.cluster.cluster_name
  common_labels      = var.common_labels
  node_pool_name     = "prod100k"
  availability_zones = data.google_compute_zones.available.names
  kubernetes_version = module.cluster.master_version

  secondary_range_name = var.create_network ? module.network.secondary_range_name_messaging_pods : var.secondary_range_name_messaging_pods

  worker_node_machine_type    = local.prod100k_machine_type
  worker_node_service_account = module.cluster.worker_node_service_account

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType     = "messaging"
    serviceClass = "prod100k"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod100k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_pool_monitoring" {
  source = "./modules/broker-node-pool"

  region             = var.region
  cluster_name       = module.cluster.cluster_name
  common_labels      = var.common_labels
  node_pool_name     = "monitoring"
  availability_zones = data.google_compute_zones.available.names
  kubernetes_version = module.cluster.master_version

  secondary_range_name = var.create_network ? module.network.secondary_range_name_messaging_pods : var.secondary_range_name_messaging_pods

  worker_node_machine_type    = local.monitoring_machine_type
  worker_node_service_account = module.cluster.worker_node_service_account

  max_pods_per_node  = var.max_pods_per_node_messaging
  node_pool_max_size = var.node_pool_max_size

  node_pool_labels = {
    nodeType = "monitoring"
  }

  node_pool_taints = [
    {
      key    = "nodeType"
      value  = "monitoring"
      effect = "NO_EXECUTE"
    }
  ]
}