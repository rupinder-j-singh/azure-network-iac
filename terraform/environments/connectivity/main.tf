# ============================================================
# Connectivity Environment — Provider and Backend
# ============================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-rs-tfstate-uks-p-001"
    storage_account_name = "strsconntfstateuksp01"
    container_name       = "tfstate"
    key                  = "hub-network/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}