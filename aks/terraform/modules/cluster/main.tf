locals {
  worker_node_username = "worker"
}

################################################################################
# Cluster
################################################################################

resource "azurerm_user_assigned_identity" "cluster" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.region
  tags                = var.common_tags
}

resource "azurerm_role_assignment" "cluster_subnet" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
}

resource "azurerm_role_assignment" "cluster_route_table" {
  scope                = var.route_table_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.cluster.principal_id
}

resource "azurerm_kubernetes_cluster" "cluster" {
  #checkov:skip=CKV_AZURE_171:Auto-upgrade disabled - Solace recommends that clusters be upgraded manually
  #checkov:skip=CKV_AZURE_117:Solace's recommended VM series use ephemeral OS disks so do not support BYOK
  #checkov:skip=CKV_AZURE_4:Solace is not opinionated on how container metrics are collected
  #checkov:skip=CKV_AZURE_7:Network Policy setting not supported when network plugin is 'kubenet'
  #checkov:skip=CKV_AZURE_116:Solace is not opinionated on the use of Azure Policy for Kubernetes

  name                = var.cluster_name
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  dns_prefix              = var.cluster_name
  private_cluster_enabled = var.kubernetes_api_public_access ? false : true
  kubernetes_version      = var.kubernetes_version
  sku_tier                = "Standard"
  local_account_disabled  = var.local_account_disabled
  node_os_upgrade_channel = "None"

  api_server_access_profile {
    authorized_ip_ranges = var.kubernetes_api_public_access ? var.kubernetes_api_authorized_networks : null
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  auto_scaler_profile {
    scale_down_unneeded        = "5m"
    scale_down_delay_after_add = "5m"
  }

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = var.worker_node_vm_size
    os_disk_size_gb = var.worker_node_os_disk_size_gb
    os_disk_type    = var.worker_node_os_disk_type
    vnet_subnet_id  = var.subnet_id
    zones           = var.availability_zones
    max_pods        = var.max_pods_per_node
    tags            = var.common_tags

    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    #checkov:skip=CKV2_AZURE_29:Solace recommends the use of the 'kubenet' network plugin, but Azure CNI can be used if desired
    network_plugin = "kubenet"
    service_cidr   = var.kubernetes_service_cidr
    dns_service_ip = var.kubernetes_dns_service_ip
    pod_cidr       = var.kubernetes_pod_cidr

    load_balancer_sku = "standard"
    load_balancer_profile {
      managed_outbound_ip_count = var.outbound_ip_count
      outbound_ports_allocated  = var.outbound_ports_allocated
    }
  }

  linux_profile {
    admin_username = local.worker_node_username
    ssh_key {
      key_data = var.worker_node_ssh_public_key
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.cluster.id]
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.kubernetes_cluster_admin_groups
  }

  depends_on = [
    azurerm_role_assignment.cluster_route_table,
    azurerm_role_assignment.cluster_subnet
  ]

  lifecycle {
    precondition {
      condition     = !var.local_account_disabled || length(var.kubernetes_cluster_admin_groups) > 0 || length(var.kubernetes_cluster_admin_users) > 0
      error_message = "At least one admin group or admin user must be provided if local accounts are disabled."
    }
  }
}

data "azuread_user" "cluster_admin" {
  count = length(var.kubernetes_cluster_admin_users)

  user_principal_name = var.kubernetes_cluster_admin_users[count.index]
}

resource "azurerm_role_assignment" "cluster_admin" {
  count = length(var.kubernetes_cluster_admin_users)

  scope                = azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azuread_user.cluster_admin[count.index].object_id
}

################################################################################
# Cluster Logs
################################################################################

resource "azurerm_log_analytics_workspace" "cluster" {
  name                = "${var.cluster_name}-logs"
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.common_tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

# https://learn.microsoft.com/en-us/azure/aks/monitor-aks
resource "azurerm_monitor_diagnostic_setting" "cluster" {
  name                       = var.cluster_name
  target_resource_id         = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.cluster.id

  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}