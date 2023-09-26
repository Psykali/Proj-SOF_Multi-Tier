resource "azurerm_service_plan" "skprjs_asp" {
  name                = "sofprd-asp"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "skprjs_webapps" {
  count               = 3
  name                = "sofprd-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp.id

  site_config {
    linux_fx_version = "DOCKER|skP20ContReg.azurecr.io/prd/stackoverp20kcab"
  }

  app_settings = {
    "WEBSITES_PORT" = "80"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.skprjs_ai.instrumentation_key
     "DATABASE_NAME"                 = var.db_name
    "MYSQL_HOST"                    = var.db_host
    "MYSQL_PORT"                    = "1433"
    "MYSQL_USER"                    = var.admin_username
    "MYSQL_PASSWORD"                = var.admin_password
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_app_service_slot" "staging" {
  count               = 3
  name                = "slot"
  app_service_name    = azurerm_app_service.skprjs_webapps[count.index].name
  location            = azurerm_app_service.skprjs_webapps[count.index].location
  resource_group_name = azurerm_app_service.skprjs_webapps[count.index].resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp.id

  tags = local.common_tags
}