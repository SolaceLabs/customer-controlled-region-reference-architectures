output "bastion_public_ip" {
  value = var.create_bastion && var.bastion_public_access ? aws_instance.bastion[0].public_ip : null
}