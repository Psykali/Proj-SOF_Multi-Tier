# MySQL Server
resource "azurerm_mysql_server" "mysql" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  administrator_login = var.mysql_server_admin_username
  administrator_login_password = var.mysql_server_admin_password
  sku_name            = "B_Gen5_1"
  version             = "5.7"
  storage_mb          = 5120
  ssl_enforcement_enabled = true
}


# MySQL Database
resource "azurerm_mysql_database" "mysql_db" {
  name                = var.mysql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "UTF8"
  collation           = "UTF8_GENERAL_CI"
}

# App Service Plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = var.app_service_sku
    size = "Small"
  }
}

## Zulip Web App
resource "azurerm_app_service" "zulip_app" {
  name                = var.zulip_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "MYSQL_SERVER_NAME"         = azurerm_mysql_server.mysql.fqdn
    "MYSQL_DATABASE_NAME"       = azurerm_mysql_database.mysql_db.name
    "MYSQL_USERNAME"            = azurerm_mysql_server.mysql.administrator_login
    "MYSQL_PASSWORD"            = azurerm_mysql_server.mysql.administrator_login_password
    "ZULIP_EXTERNAL_HOST_NAME"  = azurerm_app_service.zulip_app.default_site_hostname
    "PORT"                      = "8080"
  }
}

# GitHub Web App
resource "azurerm_app_service" "github_app" {
  name                = var.github_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "MYSQL_SERVER_NAME"         = azurerm_mysql_server.mysql.fqdn
    "MYSQL_DATABASE_NAME"       = azurerm_mysql_database.mysql_db.name
    "MYSQL_USERNAME"            = azurerm_mysql_server.mysql.administrator_login
    "MYSQL_PASSWORD"            = azurerm_mysql_server.mysql.administrator_login_password
    "GITHUB_EXTERNAL_HOST_NAME" = azurerm_app_service.github_app.default_site_hostname
    "PORT"                      = "8081"
  }
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "my-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "PublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.lb_ip.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name = "vmBackendPool"
  }
}

# Public IP Address
resource "azurerm_public_ip" "lb_ip" {
  name                = "my-lb-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Zulip Web App Backend Pool
resource "azurerm_lb_backend_address_pool" "zulip_backend_pool" {
  name                = "zulip-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
  resource_group_name = var.resource_group_name

  dynamic "ip_configuration" {
    for_each = azurerm_app_service.zulip_app.ip_addresses
    content {
      ip_address = ip_configuration.value
    }
  }
}

# GitHub Web App Backend Pool
resource "azurerm_lb_backend_address_pool" "github_backend_pool" {
  name                = "github-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
  resource_group_name = var.resource_group_name

  dynamic "ip_configuration" {
    for_each = azurerm_app_service.github_app.ip_addresses
    content {
      ip_address = ip_configuration.value
    }
  }
}

# Zulip Web App Load Balancer Rule
resource "azurerm_lb_rule" "zulip_rule" {
  name                    = "zulip-lb-rule"
  protocol                = "Tcp"
  frontend_port           = 8080
  backend_port            = 8080
  frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.zulip_backend_pool.id
}

# GitHub Web App Load Balancer Rule
resource "azurerm_lb_rule" "github_rule" {
  name                    = "github-lb-rule"
  protocol                = "Tcp"
  frontend_port           = 8081
  backend_port            = 8081
  frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.github_backend_pool.id
}
