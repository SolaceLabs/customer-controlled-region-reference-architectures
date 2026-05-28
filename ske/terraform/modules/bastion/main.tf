resource "stackit_security_group" "bastion_sg" {
  project_id = var.project_id
  name       = "${var.cluster_name}-bastion-sg"
  stateful   = true
  labels     = var.common_labels
}

resource "stackit_security_group_rule" "ssh" {
  project_id        = var.project_id
  security_group_id = stackit_security_group.bastion_sg.security_group_id
  direction         = "ingress"
  ether_type        = "IPv4"
  port_range = {
    max = 22
    min = 22
  }
  protocol = {
    name = "tcp"
  }
  ip_range = var.bastion_ssh_source_cidr

  lifecycle {
    precondition {
      condition     = var.bastion_ssh_source_cidr != ""
      error_message = "bastion_ssh_source_cidr must be provided when the bastion is created."
    }
  }
}

resource "stackit_security_group_rule" "icmp" {
  count             = var.bastion_icmp_source_cidr != "" ? 1 : 0
  project_id        = var.project_id
  security_group_id = stackit_security_group.bastion_sg.security_group_id
  direction         = "ingress"
  icmp_parameters = {
    code = 0
    type = 8
  }
  protocol = {
    name = "icmp"
  }
  ip_range = var.bastion_icmp_source_cidr
}

resource "stackit_network_interface" "bastion_nic" {
  project_id         = var.project_id
  network_id         = var.network_id
  security_group_ids = [stackit_security_group.bastion_sg.security_group_id]
  labels             = var.common_labels
}

resource "stackit_server" "bastion" {
  project_id = var.project_id
  name       = "${var.cluster_name}-bastion"
  boot_volume = {
    size        = var.boot_volume_size
    source_type = "image"
    source_id   = var.bastion_image_id
  }

  machine_type = var.machine_type
  keypair_name = stackit_key_pair.bastion_kp.name
  network_interfaces = [
    stackit_network_interface.bastion_nic.network_interface_id
  ]
  labels = var.common_labels
}

resource "stackit_public_ip" "bastion_public_ip" {
  project_id           = var.project_id
  network_interface_id = stackit_network_interface.bastion_nic.network_interface_id
  labels               = var.common_labels
}

resource "stackit_key_pair" "bastion_kp" {
  name       = "${var.cluster_name}-bastion-kp"
  public_key = var.bastion_ssh_public_key
  labels     = var.common_labels
}
