resource "google_service_account" "bastion" {
  count = var.create_bastion ? 1 : 0

  account_id   = "${var.cluster_name}-bastion"
  display_name = "Service account for ${var.cluster_name} bastion"
}

data "google_compute_zones" "available" {

}

resource "google_compute_instance" "bastion" {
  #checkov:skip=CKV_GCP_38:Solace is not opionionated on the use of CSEK for boot disks
  #checkov:skip=CKV_GCP_40:Solace is not opinionated on how compute instance is accessed - a public IP is the simplest solution

  count = var.create_bastion ? 1 : 0

  name         = "${var.cluster_name}-bastion"
  machine_type = "e2-small"
  zone         = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      size  = 20
      type  = "pd-standard"
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = var.subnetwork_name
    access_config {

    }
  }

  service_account {
    email  = google_service_account.bastion[0].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys               = "ubuntu:${var.bastion_ssh_public_key}"
    block-project-ssh-keys = true
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  lifecycle {
    precondition {
      condition     = var.bastion_ssh_public_key != ""
      error_message = "Public key must be provided if bastion host is being created."
    }

    precondition {
      condition     = var.subnetwork_name != null
      error_message = "Subnetwork name must be provided if bastion host is being created."
    }
  }
}

resource "google_compute_firewall" "bastion" {
  count = var.create_bastion ? 1 : 0

  name    = "${var.cluster_name}-bastion-ssh"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.bastion_ssh_authorized_networks

  target_service_accounts = [
    google_service_account.bastion[0].email,
  ]

  lifecycle {
    precondition {
      condition     = length(var.bastion_ssh_authorized_networks) > 0
      error_message = "At least one authorized network must be provided if bastion host is being created."
    }

    precondition {
      condition     = var.network_name != null
      error_message = "Network name must be provided if bastion host is being created."
    }
  }
}