output "bastion_instance_id" {
  value       = stackit_server.bastion.server_id
  description = "The bastion server's STACKIT server ID."
}

output "bastion_public_ip" {
  value       = stackit_public_ip.bastion_public_ip.ip
  description = "The bastion host's public IP address."
}

output "bastion_private_ip" {
  value       = stackit_network_interface.bastion_nic.ipv4
  description = "The bastion host's private IP address on the cluster network."
}

output "bastion_security_group_id" {
  value       = stackit_security_group.bastion_sg.security_group_id
  description = "ID of the bastion's security group."
}

output "bastion_username" {
  value       = "ubuntu"
  description = "The bastion host's SSH username."
}
