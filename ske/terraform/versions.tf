terraform {
  required_version = "~> 1.3"

  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.95.0"
    }
  }
}

provider "stackit" {
  default_region = var.region
}
