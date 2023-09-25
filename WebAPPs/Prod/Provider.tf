###############
## Providers ##
###############
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
    key                  = "sofwebappprod.tfstate"
  }
}

data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {}
}