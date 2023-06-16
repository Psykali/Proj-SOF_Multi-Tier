resource "azurerm_mysql_server" "SK_mariadb" {
  name                = "SK_mariadb"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  version             = "5.7"
  sku_name            = "B_Gen5_2"
  storage_profile     = "Premium_LRS"
  administrator_login = "adminuser"
  administrator_login_password = "password"
  ssl_enforcement     = "Enabled"
}

resource "azurerm_app_service_plan" "SK_app_service_plan" {
  name                = "SK_app_service_plan"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "SK_webapp_dev" {
  name                = "SK_webapp_dev"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  app_service_plan_id = azurerm_app_service_plan.SK_app_service_plan.id
}

resource "azurerm_app_service" "SK_webapp_prod" {
  name                = "SK_webapp_prod"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  app_service_plan_id = azurerm_app_service_plan.SK_app_service_plan.id
}

resource "azurerm_storage_account" "SK_storage" {
  name                     = "SKstorage${random_string.random_name.result}"
  resource_group_name      = "PERSO_SIEF"
  location                 = "francecentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_monitor_log_analytics_workspace" "SK_log_analytics" {
  name                = "SK_log_analytics"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "SK_diagnostic_setting" {
  name               = "SK_diagnostic_setting"
  target_resource_id = azurerm_app_service.SK_webapp_prod.id
  log_analytics_workspace_id = azurerm_monitor_log_analytics_workspace.SK_log_analytics.id
  log {
    category = "AppServiceHTTPLogs"
    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "SK_diagnostic_setting_dev" {
  name               = "SK_diagnostic_setting_dev"
  target_resource_id = azurerm_app_service.SK_webapp_dev.id
  log_analytics_workspace_id = azurerm_monitor_log_analytics_workspace.SK_log_analytics.id
  log {
    category = "AppServiceHTTPLogs"
    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "SK_diagnostic_setting_mariadb" {
  name               = "SK_diagnostic_setting_mariadb"
  target_resource_id = azurerm_mysql_server.SK_mariadb.id
  log_analytics_workspace_id = azurerm_monitor_log_analytics_workspace.SK_log_analytics.id
  log {
    category = "MySqlSlowLogs"
    retention_policy {
      enabled = false
    }
  }
}