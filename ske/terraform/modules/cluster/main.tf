resource "stackit_ske_cluster" "this" {
  name       = var.cluster_name
  project_id = var.project_id

  node_pools = var.node_pools

  network = {
    control_plane = {
      access_scope = var.kubernetes_api_access_scope
    }
    id = var.network_id
  }
}
