######################
## Service App Plan ##
######################
resource "azurerm_service_plan" "skprjs_asp" {
  count               = 1
  name                = "sofprdwe-asp-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name = "S1"
  os_type  = "Linux"
}
#############
## WebApps ##
#############
resource "azurerm_app_service" "skprjs_webapps" {
  count               = 1
  name                = "sofprdwe-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp[count.index].id

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
###########
## Slots ##
###########
resource "azurerm_app_service_slot" "staging" {
  count               = 1
  name                = "staging"
  app_service_name    = azurerm_app_service.skprjs_webapps[count.index].name
  location            = azurerm_app_service.skprjs_webapps[count.index].location
  resource_group_name = azurerm_app_service.skprjs_webapps[count.index].resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp[count.index].id

  tags = local.common_tags
}
######################
## Service App Plan ##
######################
resource "azurerm_service_plan" "skprjs_asp2" {
  count               = 1
  name                = "sofprdfc-asp-${count.index}"
  location            = var.location2
  resource_group_name = var.resource_group_name
  sku_name = "S1"
  os_type  = "Linux"
}
#############
## WebApps ##
#############
resource "azurerm_app_service" "skprjs_webapps2" {
  count               = 2
  name                = "sofprdfc-${count.index}"
  location            = var.location2
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp2[count.index].id

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
###########
## Slots ##
###########
resource "azurerm_app_service_slot" "staging2" {
  count               = 1
  name                = "staging"
  app_service_name    = azurerm_app_service.skprjs_webapps2[count.index].name
  location            = azurerm_app_service.skprjs_webapps2[count.index].location
  resource_group_name = azurerm_app_service.skprjs_webapps2[count.index].resource_group_name
  app_service_plan_id = azurerm_service_plan.skprjs_asp2[count.index].id

  tags = local.common_tags
}