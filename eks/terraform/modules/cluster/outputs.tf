output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "default_node_group_arn" {
  value = aws_eks_node_group.default.arn
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}

output "cluster_autoscaler_helm_values" {
  value = local.cluster_autoscaler_helm_values
}

output "load_balancer_controller_helm_values" {
  value = local.load_balancer_controller_helm_values
}