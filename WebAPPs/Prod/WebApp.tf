# Create an Application Insights instance
resource "azurerm_application_insights" "appinsights" {
  name                = "myappinsights"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create a MySQL server for the databases
resource "azurerm_mysql_server" "mysql_server" {
  name                = "my-mysql-server"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name   = "B_Gen5_1"
  storage_mb = 5120

  version = "5.7"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

# Create a MySQL database for every web app
resource "azurerm_mysql_database" "mysql_database" {
  count               = 3
  name                = "wordpress-db-${count.index}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

# Create Web Apps and App Service Plans
resource "azurerm_app_service_plan" "webapp_asp" {
  count               = 3
  name                = "webapp-asp-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "webapp" {
  count               = 3
  name                = "webapp-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.webapp_asp[count.index].id

  site_config 
              { 
                linux_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/wordpress:5.6-php8.0" 
                }
  
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    "DATABASE_NAME"                 = azurerm_mysql_database.mysql_database[count.index].name
    "MYSQL_HOST"                    = azurerm_mysql_server.mysql_server.fqdn
    "MYSQL_PORT"                    = "3306"
    "MYSQL_USER"                    = azurerm_mysql_server.mysql_server.administrator_login
    "MYSQL_PASSWORD"                = azurerm_mysql_server.mysql_server.administrator_login_password
  }

  identity {
    type = "SystemAssigned"
  }
}

# Create an App Insights resource per Web App
resource "azurerm_app_insights" "appinsights_app" {
  count               = 3
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
