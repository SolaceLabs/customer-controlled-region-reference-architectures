output "cluster_name" {
  value = google_container_cluster.cluster.name
}

output "master_version" {
  value = google_container_cluster.cluster.master_version
}

output "worker_node_service_account" {
  value = google_service_account.cluster.email
}