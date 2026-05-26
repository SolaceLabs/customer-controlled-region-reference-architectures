output "bastion_public_ip" {
  value       = stackit_public_ip.bastion_public_ip.ip
  description = "The bastion host's public IP address."
}

output "bastion_username" {
  value       = "ubuntu"
  description = "The bastion host's SSH username."
}
