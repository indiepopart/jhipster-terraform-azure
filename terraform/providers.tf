terraform {
  required_version = ">=1.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.107"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = "~> 0.49.0"
    }
  }
}

provider "azurerm" {
  features {}
}
