terraform {
  required_version = "~> 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

data "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region
}

data "google_client_config" "provider" {}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.main.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.main.master_auth[0].cluster_ca_certificate,
  )
}