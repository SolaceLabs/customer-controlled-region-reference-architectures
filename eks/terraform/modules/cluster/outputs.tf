output "cluster_name" {
  value = aws_eks_cluster.cluster.name

  depends_on = [aws_eks_cluster.cluster]
}

output "cluster_id" {
  value = aws_eks_cluster.cluster.id
}

output "cluster_security_group_id" {
  value = aws_security_group.cluster.id

  depends_on = [
    aws_security_group_rule.cluster_from_worker_node
  ]
}

output "worker_node_security_group_id" {
  value = aws_security_group.worker_node.id

  depends_on = [
    aws_security_group_rule.worker_node_from_cluster,
    aws_security_group_rule.worker_node_to_worker_node
  ]
}

output "worker_node_role_arn" {
  value = aws_iam_role.worker_node.arn

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.worker_node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.worker_node_AmazonSSMManagedInstanceCore,
  ]
}