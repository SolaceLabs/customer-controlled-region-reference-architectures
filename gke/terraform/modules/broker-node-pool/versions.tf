terraform {
  required_version = "~> 1.3"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.0.0"
    }
  }
}