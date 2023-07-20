# Rocket.Chat Web App
resource "azurerm_app_service" "rocketchat_app" {
  name                = var.rocketchat_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|rocketchat/rocket.chat:latest"
    scm_type         = "None"
  }

  app_settings = {
    "MONGO_URL"       = azurerm_cosmosdb_account.cosmosdb.connection_strings[0]
    "MONGO_OPLOG_URL" = azurerm_cosmosdb_account.cosmosdb.connection_strings[0]
    "ROOT_URL"        = var.rocketchat_root_url
    "MAIL_URL"        = var.rocketchat_mail_url
    "PORT"            = "3000"
  }
}