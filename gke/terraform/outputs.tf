output "project" {
  value = var.project
}

output "region" {
  value = var.region
}

output "cluster_name" {
  value = var.cluster_name
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "kubernetes_api_public_access" {
  value = var.kubernetes_api_public_access
}