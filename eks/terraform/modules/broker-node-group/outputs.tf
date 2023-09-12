output "node_group_arns" {
  value = aws_eks_node_group.this[*].arn
}