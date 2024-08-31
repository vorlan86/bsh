terraform {
  required_version = ">= 1.3.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.1"
    }
  }
}

terraform {
#   backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  # client_id       = var.azurerm_client_id
  # client_secret   = var.azurerm_client_secret
  features {}
}
