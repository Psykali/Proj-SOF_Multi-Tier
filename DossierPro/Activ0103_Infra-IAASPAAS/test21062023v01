resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_mysql_server" "sk_mysql_server" {
  name                = "sk-mysql-server"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  sku_name            = "B_Gen5_2"
  storage_profile {
    storage_mb                    = 5120
    backup_retention_days         = 7
    geo_redundant_backup_enabled  = true
    geo_redundant_backup_interval = 30
  }
}

resource "azurerm_app_service" "sk_app_service" {
  name                = "sk-app-service"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  app_service_plan_id = azurerm_app_service_plan.sk_app_service_plan.id
}

resource "azurerm_app_service_plan" "sk_app_service_plan" {
  name                = "sk-app-service-plan"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_storage_account" "sk_storage_account" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.sk_rg.name
  location                 = azurerm_resource_group.sk_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_application_insights" "sk_app_insights" {
  name                = "sk-application-insights"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
}

resource "azurerm_role_assignment" "sk_role_assignment" {
  scope                = azurerm_resource_group.sk_rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_app_service.sk_app_service.identity[0].principal_id
}

resource "azurerm_monitor_metric_alert" "sk_metric_alert" {
  name                = "sk-metric-alert"
  resource_group_name = azurerm_resource_group.sk_rg.name
  scopes              = [azurerm_app_service.sk_app_service.id]
  description         = "High CPU usage alert"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    operator         = "GreaterThan"
    threshold        = 90
    time_aggregation = "Average"
  }

  action {
    action_group_id = azurerm_monitor_action_group.sk_action_group.id
  }
}

resource "azurerm_monitor_action_group" "sk_action_group" {
  name                = "sk-action-group"
  resource_group_name = azurerm_resource_group.sk_rg.name

  email_receiver {
    name          = "email-receiver"
    email_address = "youremail@example.com"
  }
}

resource "azurerm_log_analytics_workspace" "sk_log_analytics_workspace" {
  name                = "sk-log-analytics-workspace"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "sk_diagnostic_setting" {
  name                       = "sk-diagnostic-setting"
  target_resource_id         = azurerm_app_service.sk_app_service.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.sk_log_analytics_workspace.id
  logs = [
    {
      category = "AppServiceConsoleLogs"
      enabled  = false
    },
    {
      category = "AppServiceFileAuditLogs"
      enabled  = true
    },
  ]
}

resource "azurerm_template_deployment" "sk_template_deployment" {
  name                = "sk-template-deployment"
  resource_group_name = azurerm_resource_group.sk_rg.name
  template_content    = filebase64("template.json")
  parameters_content  = filebase64("parameters.json")
}