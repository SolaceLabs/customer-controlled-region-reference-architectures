output "kubeconfig" {
  sensitive = true
  value     = stackit_ske_kubeconfig.this.kube_config
}
