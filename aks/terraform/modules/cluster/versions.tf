terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }
}
