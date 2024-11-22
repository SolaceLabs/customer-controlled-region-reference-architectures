resource "azurerm_kubernetes_cluster_node_pool" "this" {
  count = length(var.availability_zones)

  name = "${var.node_pool_name}${count.index}"
  tags = var.common_tags

  kubernetes_cluster_id = var.cluster_id

  orchestrator_version = var.kubernetes_version

  min_count = 0
  max_count = var.node_pool_max_size

  auto_scaling_enabled = true

  max_pods = var.worker_node_max_pods

  zones          = [var.availability_zones[count.index]]
  vnet_subnet_id = var.subnet_id

  vm_size         = var.worker_node_vm_size
  os_disk_type    = "Ephemeral"
  os_disk_size_gb = var.worker_node_disk_size

  node_labels = var.node_pool_labels
  node_taints = var.node_pool_taints
}