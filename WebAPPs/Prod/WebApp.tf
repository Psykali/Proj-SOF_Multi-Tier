# Create an Application Insights instance
resource "azurerm_application_insights" "appinsights" {
  name                = "myappinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create Web Apps and App Service Plans
resource "azurerm_app_service_plan" "webapp_asp" {
  count               = 1
  name                = "prd-asp-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "webapp" {
  count               = 1
  name                = "prod-Sof-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.webapp_asp[count.index].id

  site_config {
    linux_fx_version = "DOCKER|${var.docker_registry_server_url}/prd/stackoverp20kcab"
    always_on        = true

    docker_registry_server_url      = var.docker_registry_server_url
    docker_registry_server_user     = var.docker_registry_server_user
    docker_registry_server_password = var.docker_registry_server_password
  }


  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    "DATABASE_NAME"                 = var.db_name
    "MYSQL_HOST"                    = var.db_host
    "MYSQL_PORT"                    = "1433"
    "MYSQL_USER"                    = var.admin_username
    "MYSQL_PASSWORD"                = var.admin_password
  }

  identity {
    type = "SystemAssigned"
  }
}

# Create an App Insights resource per Web App
resource "azurerm_app_insights" "appinsights_app" {
  count               = 1
  name                = "app-${count.index}-insights"
  resource_group_name = var.resource_group_name
  application_id      = azurerm_application_insights.appinsights.application_id
  application_type    = "web"

  location       = azurerm_application_insights.appinsights.location
  tags           = local.common_tags
  correlation {
    client_track_enabled = false
  }
  web {
    app_id = azurerm_app_service.webapp[count.index].id
  }
}

# Output the Web App URLs
output "webapp_urls" {
  value = [
    for i in range(0, 3):
    "https://${azurerm_app_service.webapp[i].default_site_hostname}/"
  ]
}
