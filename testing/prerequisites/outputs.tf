output "local_cidr" {
  value = "${chomp(data.http.ip.response_body)}/32"
}

output "bastion_ssh_public_key" {
  value = tls_private_key.bastion.public_key_openssh
}

output "bastion_ssh_private_key" {
  sensitive = true
  value     = tls_private_key.bastion.private_key_pem
}