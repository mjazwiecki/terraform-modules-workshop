terraform {
  required_version = "= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.0.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
