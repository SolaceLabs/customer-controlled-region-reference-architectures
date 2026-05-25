output "bastion_public_ip" {
  value       = var.create_bastion ? stackit_public_ip.bastion_public_ip[0].ip : null
  description = "The bastion host's public IP address. Null when create_bastion is false."
}

output "bastion_username" {
  value       = var.create_bastion ? "ubuntu" : null
  description = "The bastion host's SSH username. Null when create_bastion is false."
}
