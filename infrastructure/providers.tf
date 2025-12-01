terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.1.0"
    }

    azapi = {
      source = "azure/azapi"
      version = ">=2.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">=3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name = "rg-infrastructure"
    container_name      = "ai-foundry-reference-architecture"
    key                 = "terraform.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  storage_use_azuread = true
}

provider "azapi" {
  subscription_id = var.subscription_id
}

provider "random" {}