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

  outbound_ip_count        = var.outbound_ip_count
  outbound_ports_allocated = var.outbound_ports_allocated

  worker_node_vm_size        = var.system_vm_size
  worker_node_ssh_public_key = var.worker_node_ssh_public_key
  worker_node_os_disk_type   = "Managed"

  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.kubernetes_api_authorized_networks

  local_account_disabled          = var.local_account_disabled
  kubernetes_cluster_admin_groups = var.kubernetes_cluster_admin_groups
  kubernetes_cluster_admin_users  = var.kubernetes_cluster_admin_users
}

################################################################################
# Node Pools
################################################################################

locals {
  os_disk_size_gb = 48
}

module "node_pool_messaging" {
  for_each = var.messaging_node_pools
  source   = "./modules/broker-node-pool"

  cluster_id     = module.cluster.cluster_id
  node_pool_name = each.key

  kubernetes_version = module.cluster.current_kubernetes_version

  subnet_id = var.create_network ? module.network.subnet_id : var.subnet_id

  node_pool_max_size    = var.node_pool_max_size
  worker_node_vm_size   = each.value.vm_size
  worker_node_disk_size = local.os_disk_size_gb

  node_pool_labels = {
    serviceClass = each.key
    nodeType     = "messaging"
  }

  node_pool_taints = [
    "serviceClass=${each.key}:NoExecute",
    "nodeType=messaging:NoExecute"
  ]
}

module "node_pool_monitoring" {
  source = "./modules/broker-node-pool"

  cluster_id     = module.cluster.cluster_id
  node_pool_name = "monitoring"

  kubernetes_version = module.cluster.current_kubernetes_version

  subnet_id = var.create_network ? module.network.subnet_id : var.subnet_id

  node_pool_max_size    = var.node_pool_max_size
  worker_node_vm_size   = var.monitoring_vm_size
  worker_node_disk_size = local.os_disk_size_gb
  worker_node_disk_type = "Managed"

  node_pool_labels = {
    nodeType                                                  = "monitoring",
    "node.kubernetes.io/exclude-from-external-load-balancers" = "true"
  }

  node_pool_taints = [
    "nodeType=monitoring:NoExecute"
  ]
}