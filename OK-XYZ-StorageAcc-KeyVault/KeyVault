## Create KeyVault
resource "azurerm_key_vault" "sppersosecrets" {
  name = "sppersosecrets"
  resource_group_name = "PERSO_SIEF"
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
##resource "azurerm_key_vault_secret" "hello_secret" {
##  name = "hellosecret"
##  value = "hello world"
##  key_vault_id = "${azurerm_key_vault.sppersosecrets.id}"
##}
##