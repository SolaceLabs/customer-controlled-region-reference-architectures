output "project_id" {
  value       = stackit_resourcemanager_project.cluster.project_id
  description = "ID of the created STACKIT project."
}

output "network_area_id" {
  value       = module.network.network_area_id
  description = "ID of the organization-scoped STACKIT network area."
}

output "network_id" {
  value       = module.network.network_id
  description = "ID of the project-scoped network."
}

output "cluster_name" {
  value       = module.cluster.cluster_name
  description = "Name of the SKE cluster."
}

output "kubernetes_api_public_access" {
  value       = var.kubernetes_api_access_scope == "PUBLIC"
  description = "Whether the cluster's Kubernetes API is publicly accessible. Derived from kubernetes_api_access_scope; matches the AKS/EKS/GKE output name so connect.sh can use the same logic."
}

output "bastion_public_ip" {
  value       = one(module.bastion[*].bastion_public_ip)
  description = "Public IP of the bastion host (null when create_bastion is false)."
}

output "bastion_username" {
  value       = one(module.bastion[*].bastion_username)
  description = "SSH username for the bastion host (null when create_bastion is false)."
}
