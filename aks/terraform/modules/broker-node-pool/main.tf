resource "azurerm_kubernetes_cluster_node_pool" "this" {
  count = var.split_node_group ? length(var.availability_zones) : 1

  name = "${var.node_pool_name}${count.index}"
  tags = var.common_tags

  kubernetes_cluster_id = var.cluster_id

  orchestrator_version = var.kubernetes_version

  os_type = "Linux"
  os_sku  = "Ubuntu"

  min_count = 0
  max_count = var.node_pool_max_size

  auto_scaling_enabled = true

  max_pods = var.max_pods_per_node

  zones          = var.split_node_group ? [var.availability_zones[count.index]] : var.availability_zones
  vnet_subnet_id = var.subnet_id

  vm_size         = var.worker_node_vm_size
  os_disk_type    = var.worker_node_disk_type
  os_disk_size_gb = var.worker_node_disk_size

  node_labels = var.node_pool_labels
  node_taints = var.node_pool_taints
}
