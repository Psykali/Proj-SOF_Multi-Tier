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
  name = var.storage_account_name
  resource_group_name = var.resource_group_name
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
##
## Create Blobs
##resource "azurerm_storage_blob" "hello_blob" {
##  name = "SaKvTF"
##  storage_account_name = azurerm_storage_account.sppersotfstates.name
##  storage_container_name = azurerm_storage_container.hello_container.name
##  source_content         = "Hello, world!"
##""}
##
## Create KeyVault
resource "azurerm_key_vault" "sppersosecrets" {
  name = "sppersosecrets"
  resource_group_name = var.resource_group_name
  location = "francecentral"
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
## Create Secrets
resource "azurerm_key_vault_secret" "hello_secret" {
  name = "hellosecret"
  value = "hello world"
  key_vault_id = "${azurerm_key_vault.sppersosecrets.id}"
tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
  }
}
##
# Terraform OutPut
# Write the Terraform output to a local file
resource "local_file" "output" {
  content  = jsonencode(terraform.workspace)
  filename = "${path.module}/output.json"
}

# Upload the local file to an Azure Blob storage container
resource "azurerm_storage_blob" "output" {
  name                   = "output.json"
  storage_account_name   = azurerm_storage_account.sppersotfstates.name
  storage_container_name = azurerm_storage_container.hello_container.name
  type                   = "Block"
  source                 = local_file.output.filename
}