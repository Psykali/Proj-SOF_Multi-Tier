##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################
## Create Storage Acc
resource "azurerm_storage_account" "sppersotfstates" {
  name = "sppersotfstates"
  resource_group_name = var.resource_group_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"

  tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
## Create Blobs
resource "azurerm_storage_blob" "hello_blob" {
  name = "hello_blob"
  storage_account_name = "sppersotfstates"
  container_name = "hello_container"
  content = "Hello, world!"

tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
## Create KeyVault
resource "azurerm_key_vault" "sppersosecrets" {
  name = "sppersosecrets"
  resource_group_name = var.resource_group_name
  location = var.location

tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
## Create Secrets
resource "azurerm_key_vault_secret" "hello_secret" {
  name = "hello_secret"
  value = "hello world"
  key_vault_id = "${azurerm_key_vault.sppersosecrets.id}"
tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}