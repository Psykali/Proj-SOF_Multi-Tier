##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################
resource "azurerm_storage_account" "sppersotfstates" {
  name = "sppersotfstates"
  resource_group_name = var.resource_group_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_blob" "hello_blob" {
  name = "hello_blob"
  storage_account_name = "sppersotfstates"
  container_name = "hello_container"
  content = "Hello, world!"
}
resource "azurerm_key_vault" "sppersosecrets" {
  name = "sppersosecrets"
  resource_group_name = var.resource_group_name
  location = var.location
}
resource "azurerm_key_vault_secret" "hello_secret" {
  name = "hello_secret"
  value = "hello world"
  key_vault_id = "${azurerm_key_vault.sppersosecrets.id}"
}