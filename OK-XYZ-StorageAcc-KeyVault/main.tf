data "azurerm_client_config" "current" {}

###########################################
## Create Resource Group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################
## Create Storage Acc
resource "azurerm_storage_account" "sppersotfstates" {
  name = "sppersotfstates"
  resource_group_name = "PERSO_SIEF"
  location = "francecentral"
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
## Create Container
resource "azurerm_storage_container" "hello_container" {
  name                  = "sakvtfstate"
  storage_account_name  = azurerm_storage_account.sppersotfstates.name
}