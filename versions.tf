terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0"
    }
  }
}

provider "azurerm" {
  subscription_id            = var.subscriptionid
  tenant_id                  = var.tenantid
  skip_provider_registration = true
  features {}
}
