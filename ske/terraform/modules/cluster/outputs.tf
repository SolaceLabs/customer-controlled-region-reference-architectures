output "cluster_name" {
  value       = stackit_ske_cluster.this.name
  description = "Name of the SKE cluster."
}

output "cluster_id" {
  value       = stackit_ske_cluster.this.id
  description = "Terraform internal resource ID of the cluster, structured as project_id,region,name."
}

output "kubernetes_version_used" {
  value       = stackit_ske_cluster.this.kubernetes_version_used
  description = "Full kubernetes version currently used by the cluster."
}

output "pod_address_ranges" {
  value       = stackit_ske_cluster.this.pod_address_ranges
  description = "Network ranges (CIDR) used by pods in the cluster. Auto-assigned by STACKIT from the CGNAT range 100.64.0.0/10."
}

output "egress_address_ranges" {
  value       = stackit_ske_cluster.this.egress_address_ranges
  description = "Outgoing network ranges (CIDR) of traffic originating from cluster workloads."
}
