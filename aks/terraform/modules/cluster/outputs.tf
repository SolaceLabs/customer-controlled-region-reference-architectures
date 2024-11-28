output "cluster_name" {
  value = azurerm_kubernetes_cluster.cluster.name

  depends_on = [
    azurerm_kubernetes_cluster.cluster
  ]
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "current_kubernetes_version" {
  value = azurerm_kubernetes_cluster.cluster.current_kubernetes_version
}