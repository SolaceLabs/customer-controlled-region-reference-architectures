output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "default_node_group_arn" {
  value = aws_eks_node_group.default.arn
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id
}

output "worker_node_security_group_id" {
  value = aws_security_group.worker_node.id
}

output "worker_node_role_arn" {
  value = aws_iam_role.worker_node.arn
}