output "node_pools" {
  value       = local.node_pools
  description = "List of node pool config objects, one per zone in var.availability_zones. Shape matches the schema expected by stackit_ske_cluster.node_pools. Calling code uses concat() to assemble multiple module outputs into the cluster's full node_pools argument."
}
