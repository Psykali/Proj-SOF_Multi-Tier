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
}

provider "azurerm" {
  features {}
}