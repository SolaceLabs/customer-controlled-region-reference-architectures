################################################################################
# Project (organization-scoped container for the cluster)
################################################################################

resource "stackit_resourcemanager_project" "cluster" {
  parent_container_id = var.organization_id
  name                = var.cluster_name
  owner_email         = var.owner_email
  labels = merge(
    var.common_labels,
    {
      "networkArea" = module.network.network_area_id
    },
  )
}

################################################################################
# Network (SNA + SNA region binding + project-scoped network)
################################################################################

module "network" {
  source = "./modules/network"

  organization_id       = var.organization_id
  project_id            = stackit_resourcemanager_project.cluster.project_id
  name                  = var.cluster_name
  region                = var.region
  cluster_cidr          = var.cluster_cidr
  additional_sna_ranges = var.additional_sna_ranges
  transfer_network_cidr = var.transfer_network_cidr
  network_dns_servers   = var.network_dns_servers
  common_labels         = var.common_labels
}

################################################################################
# Bastion
################################################################################

module "bastion" {
  source = "./modules/bastion"
  count  = var.create_bastion ? 1 : 0

  cluster_name = var.cluster_name
  project_id   = stackit_resourcemanager_project.cluster.project_id
  network_id   = module.network.network_id

  bastion_ssh_public_key   = var.bastion_ssh_public_key
  bastion_image_id         = var.bastion_image_id
  bastion_ssh_source_cidr  = var.bastion_ssh_source_cidr
  bastion_icmp_source_cidr = var.bastion_icmp_source_cidr
  common_labels            = var.common_labels
}

################################################################################
# Node Pools (config-factory; STACKIT has no standalone node_pool resource)
################################################################################

locals {
  # Sized for Solace Cloud broker workloads. See README for the per-tier rationale.
  default_machine_type    = "c2i.2"
  monitoring_machine_type = "g3i.2"
  prod1k_machine_type     = "m2i.2"
  prod10k_machine_type    = "m2i.4"
  prod100k_machine_type   = "m2i.8"

  # System pool stays inline — special shape (allow_system_components, fixed scaling, metro AZ).
  default_pool = {
    name                    = "default"
    availability_zones      = ["${var.region}-m"]
    machine_type            = local.default_machine_type
    volume_size             = var.node_pool_volume_size
    volume_type             = var.node_pool_volume_type
    allow_system_components = true
    maximum                 = 3
    minimum                 = 1
    max_surge               = 1
    max_unavailable         = 1
  }

  monitoring_labels_and_taints = {
    labels = {
      nodeType = "monitoring"
    }
    taints = [
      { key = "nodeType", value = "monitoring", effect = "NoExecute" },
    ]
  }

  prod1k_labels_and_taints = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod1k"
    }
    taints = [
      { key = "nodeType", value = "messaging", effect = "NoExecute" },
      { key = "serviceClass", value = "prod1k", effect = "NoExecute" },
    ]
  }

  prod10k_labels_and_taints = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod10k"
    }
    taints = [
      { key = "nodeType", value = "messaging", effect = "NoExecute" },
      { key = "serviceClass", value = "prod10k", effect = "NoExecute" },
    ]
  }

  prod100k_labels_and_taints = {
    labels = {
      nodeType     = "messaging"
      serviceClass = "prod100k"
    }
    taints = [
      { key = "nodeType", value = "messaging", effect = "NoExecute" },
      { key = "serviceClass", value = "prod100k", effect = "NoExecute" },
    ]
  }
}

module "node_pool_monitoring" {
  source = "./modules/broker-node-pool"

  pool_name_prefix   = "monitoring"
  region             = var.region
  availability_zones = ["3"]
  machine_type       = local.monitoring_machine_type
  volume_size        = var.node_pool_volume_size
  volume_type        = var.node_pool_volume_type
  min_size           = var.worker_node_pool_min_size
  max_size           = var.node_pool_max_size
  node_pool_labels   = local.monitoring_labels_and_taints.labels
  node_pool_taints   = local.monitoring_labels_and_taints.taints
}

module "node_pool_prod1k" {
  source = "./modules/broker-node-pool"

  pool_name_prefix   = "prod1k"
  region             = var.region
  availability_zones = ["1", "2"]
  machine_type       = local.prod1k_machine_type
  volume_size        = var.node_pool_volume_size
  volume_type        = var.node_pool_volume_type
  min_size           = var.worker_node_pool_min_size
  max_size           = var.node_pool_max_size
  node_pool_labels   = local.prod1k_labels_and_taints.labels
  node_pool_taints   = local.prod1k_labels_and_taints.taints
}

module "node_pool_prod10k" {
  source = "./modules/broker-node-pool"

  pool_name_prefix   = "prod10k"
  region             = var.region
  availability_zones = ["1", "2"]
  machine_type       = local.prod10k_machine_type
  volume_size        = var.node_pool_volume_size
  volume_type        = var.node_pool_volume_type
  min_size           = var.worker_node_pool_min_size
  max_size           = var.node_pool_max_size
  node_pool_labels   = local.prod10k_labels_and_taints.labels
  node_pool_taints   = local.prod10k_labels_and_taints.taints
}

module "node_pool_prod100k" {
  source = "./modules/broker-node-pool"

  pool_name_prefix   = "prod100k"
  region             = var.region
  availability_zones = ["1", "2"]
  machine_type       = local.prod100k_machine_type
  volume_size        = var.node_pool_volume_size
  volume_type        = var.node_pool_volume_type
  min_size           = var.worker_node_pool_min_size
  max_size           = var.node_pool_max_size
  node_pool_labels   = local.prod100k_labels_and_taints.labels
  node_pool_taints   = local.prod100k_labels_and_taints.taints
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  cluster_name       = var.cluster_name
  project_id         = stackit_resourcemanager_project.cluster.project_id
  network_id         = module.network.network_id
  kubernetes_version = var.kubernetes_version

  node_pools = concat(
    [local.default_pool],
    module.node_pool_monitoring.node_pools,
    module.node_pool_prod1k.node_pools,
    module.node_pool_prod10k.node_pools,
    module.node_pool_prod100k.node_pools,
  )

  kubernetes_api_public_access = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = concat(
    var.kubernetes_api_authorized_networks,
    var.create_bastion ? ["${module.bastion[0].bastion_public_ip}/32"] : [],
  )

  dns_enabled               = var.dns_enabled
  dns_zones                 = var.dns_zones
  observability_enabled     = var.observability_enabled
  observability_instance_id = var.observability_instance_id
}
