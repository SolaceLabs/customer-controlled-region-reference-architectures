terraform {
  required_version = "~> 1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.80.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.6.0"
    }
  }
}