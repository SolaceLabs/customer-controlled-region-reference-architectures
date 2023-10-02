output "bastion_public_ip" {
  value = var.create_bastion ? google_compute_instance.bastion[0].network_interface[0].access_config[0].nat_ip : null
}