# Create an App Service Plan
resource "azurerm_app_service_plan" "wordpress_asp" {
  name                = "wordpress-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create a MySQL Database
resource "azurerm_mysql_database" "wordpress_db" {
  name                = "wordpress-db"
  location            = var.location
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.wordpress_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

# Create a MySQL Server
resource "azurerm_mysql_server" "wordpress_server" {
  name                = "wordpress-mysql"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "B_Gen5_1"
  version             = "5.7"
  storage_mb          = 5120
  administrator_login = "wordpressadmin"
  administrator_login_password = "P@ssw0rd1234!"
}

# Create a WordPress App Service on Linux
resource "azurerm_app_service" "wordpress_app" {
  name                = "wordpress-site"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.wordpress_asp.id

  site_config {
    linux_fx_version = "DOCKER|mcr.microsoft.com/azure-app-service/wordpress:5.6-php8.0"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_USERNAME" = var.registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = var.registry_password
    "WORDPRESS_DB_HOST"               = azurerm_mysql_server.wordpress_server.fqdn
    "WORDPRESS_DB_NAME"               = azurerm_mysql_database.wordpress_db.name
    "WORDPRESS_DB_USER"               = "wordpressadmin"
    "WORDPRESS_DB_PASSWORD"           = "P@ssw0rd1234!"
    "APPINSIGHTS_INSTRUMENTATIONKEY"  = azurerm_application_insights.wordpress_ai.instrumentation_key
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Create an Application Insights for WordPress
resource "azurerm_application_insights" "wordpress_ai" {
  name                = "wordpress-ai"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create an App Insights resource for WordPress App Service
resource "azurerm_app_insights" "wordpress_appinsights" {
  name                = "wordpress-appinsights"
  resource_group_name = var.resource_group_name
  application_type    = "web"
  application_id      = azurerm_application_insights.wordpress_ai.application_id

  depends_on = [
    azurerm_application_insights.wordpress_ai,
  ]

  location       = azurerm_application_insights.wordpress_ai.location
  tags           = local.common_tags
  correlation {
    client_track_enabled = false
  }
  web {
    app_id = azurerm_app_service.wordpress_app.id
  }
}

# Create a MySQL Firewall Rule
resource "azurerm_mysql_firewall_rule" "wordpress_firewall" {
  name                = "wordpress-firewall"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.wordpress_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Output the WordPress App Service URL
output "wordpress_url" {
  value = "https://${azurerm_app_service.wordpress_app.default_site_hostname}/wp-admin/install.php"
}