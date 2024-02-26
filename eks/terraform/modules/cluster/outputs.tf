output "cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "worker_node_role_arn" {
  value = aws_iam_role.worker_node.arn
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