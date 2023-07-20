terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "PERSO_SIEF"
    storage_account_name = "sppersotfstates"
    container_name       = "sakvtfstate"
    key                  = "rcwikiterraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}