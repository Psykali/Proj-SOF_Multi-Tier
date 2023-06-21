resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_mysql_server" "sk_mysql_server" {
  name                = "sk-mysql-server"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  sku_name            = "B_Gen5_2"
  version             = "8.0"  # Specify the desired version of MySQL server
  ssl_enforcement_enabled = true  # Enable or disable SSL enforcement
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

resource "azurerm_app_service" "sk_app_service" {
  name                = "sk-app-service"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  app_service_plan_id = azurerm_app_service_plan.sk_app_service_plan.id
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
  application_type    = "web"  # Specify the appropriate application type
}

resource "azurerm_monitor_action_group" "sk_action_group" {
  name                = "sk-action-group"
  resource_group_name = azurerm_resource_group.sk_rg.name
  short_name          = "action-group"

  email_receiver {
    name          = "email-receiver"
    email_address = "youremail@example.com"
  }
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
    aggregation      = "Average"
  }

  action {
    action_group_id = azurerm_monitor_action_group.sk_action_group.id
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

  metric {
    category = "AllMetrics"
  }

  log {
    category = "AppServiceConsoleLogs"
    enabled  = true
  }

  log {
    category = "AppServiceAuditLogs"
    enabled  = true
  }
}

resource "azurerm_template_deployment" "sk_template_deployment" {
  name                = "sk-template-deployment"
  resource_group_name = azurerm_resource_group.sk_rg.name
  deployment_mode     = "Complete"  # Specify the desired deployment mode

  template_body = <<EOF
    {
      "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
      "contentVersion": "1.0.0.0",
      "parameters": {
        "location": {
          "type": "string",
          "defaultValue": "francecentral"
        }
      },
      "resources": [
        {
          "type": "Microsoft.Web/sites",
          "name": "sk-template-site",
          "apiVersion": "2021-04-01",
          "location": "[parameters('location')]",
          "properties": {
            "siteConfig": {
              "appSettings": [
                {
                  "name": "MySetting",
                  "value": "MyValue"
                }
              ]
            }
          }
        }
      ]
    }
  EOF

  parameters = {
    "location" = {
      "value" = "francecentral"
    }
  }
}