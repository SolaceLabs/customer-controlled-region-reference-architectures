resource "kubernetes_manifest" "storageclass" {
  manifest = yamldecode(file(var.storage_class_path))
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: https://${data.google_container_cluster.main.endpoint}
    certificate-authority-data: ${data.google_container_cluster.main.master_auth[0].cluster_ca_certificate}
  name: ${data.google_container_cluster.main.id}
contexts:
- context:
    cluster: ${data.google_container_cluster.main.id}
    user: user
  name: ${data.google_container_cluster.main.id}
current-context: ${data.google_container_cluster.main.id}
kind: Config
preferences: {}
users:
- name: user
  user:
      exec:
        apiVersion: client.authentication.k8s.io/v1beta1
        command: gke-gcloud-auth-plugin
        interactiveMode: IfAvailable
        provideClusterInfo: true
KUBECONFIG
}