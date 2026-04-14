output "vpc_id" {
  value = var.create_network ? aws_vpc.this[0].id : null
}

output "public_subnets" {
  value = var.create_network ? aws_subnet.public[*].id : null
}

output "private_subnets" {
  value = var.create_network ? aws_subnet.private[*].id : null

  depends_on = [aws_nat_gateway.nat]
}

output "secondary_public_subnets" {
  value = var.create_network && var.secondary_vpc_cidr != null ? aws_subnet.secondary_public[*].id : null
}

output "secondary_private_subnets" {
  value = var.create_network && var.secondary_vpc_cidr != null ? aws_subnet.secondary_private[*].id : null

  depends_on = [aws_nat_gateway.secondary_nat]
}