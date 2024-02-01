terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.89.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.46.0"
    }
  }
}
