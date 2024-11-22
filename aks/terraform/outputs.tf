output "resource_group_name" {
  value = azurerm_resource_group.cluster.name
}

output "cluster_name" {
  value = var.cluster_name
}

output "bastion_public_ip" {
  value = var.create_bastion ? module.bastion.bastion_public_ip : null
}

output "bastion_username" {
  value = var.create_bastion ? module.bastion.bastion_username : null
}

output "kubernetes_api_public_access" {
  value = var.kubernetes_api_public_access
}

output "current_kubernetes_version" {
  value = module.cluster.current_kubernetes_version
}