#provider "azurerm" {
#  features {}
#}

#resource "azurerm_resource_group" "example" {
#  name     = "PERSO_SIEF"
#  location = "France Central"
#}

resource "azurerm_app_service_plan" "example" {
  name                = "app-service-plan"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "my-webapp"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.8"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "ASPNETCORE_ENVIRONMENT"        = "Production"
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "app-insights"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  application_type = "web"
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name                       = "app-diagnostic-setting"
  target_resource_id         = azurerm_app_service.example.id
  storage_account_id         = azurerm_storage_account.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  log {
    category = "AppServiceConsoleLogs"
    enabled  = false
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "app-log-analytics"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "example" {
  name                     = "appstorage${random_string.example.id}"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "example" {
  length  = 8
  special = false
}

output "webapp_url" {
  value = azurerm_app_service.example.default_site_hostname
}
