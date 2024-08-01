terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }
}
