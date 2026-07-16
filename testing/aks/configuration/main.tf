resource "kubernetes_manifest" "storageclass" {
  manifest = yamldecode(file(var.storage_class_path))
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${data.azurerm_kubernetes_cluster.main.kube_admin_config[0].host}
    certificate-authority-data: ${data.azurerm_kubernetes_cluster.main.kube_admin_config[0].cluster_ca_certificate}
${var.proxy_url != "" ? "    proxy-url: ${var.proxy_url}" : ""}
  name: ${var.cluster_name}
contexts:
- context:
    cluster: ${var.cluster_name}
    user: clusterAdmin
  name: ${var.cluster_name}
current-context: ${var.cluster_name}
kind: Config
preferences: {}
users:
- name: clusterAdmin
  user:
    client-certificate-data: ${data.azurerm_kubernetes_cluster.main.kube_admin_config[0].client_certificate}
    client-key-data: ${data.azurerm_kubernetes_cluster.main.kube_admin_config[0].client_key}
KUBECONFIG
}