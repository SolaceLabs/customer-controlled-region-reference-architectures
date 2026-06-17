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

output "current_kubernetes_version" {
  value       = module.cluster.kubernetes_version_used
  description = "Kubernetes version currently in use by the cluster."
}

output "pod_address_ranges" {
  value       = module.cluster.pod_address_ranges
  description = "Network ranges (CIDR) used by pods in the cluster."
}

output "egress_address_ranges" {
  value       = module.cluster.egress_address_ranges
  description = "Outgoing network ranges (CIDR) of traffic originating from cluster workloads."
}

output "bastion_public_ip" {
  value       = one(module.bastion[*].bastion_public_ip)
  description = "Public IP of the bastion host (null when create_bastion is false)."
}

output "bastion_private_ip" {
  value       = one(module.bastion[*].bastion_private_ip)
  description = "Private IP of the bastion host on the cluster network (null when create_bastion is false)."
}

output "bastion_username" {
  value       = one(module.bastion[*].bastion_username)
  description = "SSH username for the bastion host (null when create_bastion is false)."
}
