output "kubeconfig" {
  sensitive = true
  value     = data.azurerm_kubernetes_cluster.main.kube_admin_config_raw
}