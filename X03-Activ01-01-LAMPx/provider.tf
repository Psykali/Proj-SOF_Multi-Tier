terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
   backend "local" {
    path = "tfstate/terraform.tfstate"
  }
##  backend "azurerm" {
##    resource_group_name  = "PERSO_SIEF"
##    storage_account_name = "sppersotfstates"
##    container_name       = "lampxvirtminstate"
##    key                  = "terraform.tfstate"
##  }
}

provider "azurerm" {
  features {}
}