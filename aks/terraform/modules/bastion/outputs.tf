output "bastion_public_ip" {
  value = var.create_bastion ? azurerm_public_ip.bastion[0].ip_address : null
}

output "bastion_username" {
  value = local.bastion_username
}