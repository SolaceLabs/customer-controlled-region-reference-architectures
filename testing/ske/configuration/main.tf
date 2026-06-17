resource "stackit_ske_kubeconfig" "this" {
  project_id   = var.project_id
  cluster_name = var.cluster_name
  expiration   = 86400

  lifecycle {
    replace_triggered_by = [terraform_data.kubeconfig_refresh.id]
  }
}

# Force kubeconfig recreation on every apply to ensure credentials are fresh.
resource "terraform_data" "kubeconfig_refresh" {
  input = timestamp()
}
