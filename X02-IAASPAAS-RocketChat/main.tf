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
    tier = "Standard"
    size = "S1"
  }
}
# Zulip Web App
resource "azurerm_app_service" "zulip_app" {
  name                = var.zulip_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|zulip/docker-zulip:4.8-0"
    scm_type         = "None"
  }

  app_settings = {
    "SECRETS_email_password"      = var.zulip_email_password
    "SECRETS_rabbitmq_password"   = var.zulip_rabbitmq_password
    "SECRETS_postgres_password"   = var.zulip_postgres_password
    "SECRETS_memcached_password"  = var.zulip_memcached_password
    "SECRETS_redis_password"      = var.zulip_redis_password
    "SETTING_EXTERNAL_HOST"       = var.zulip_external_host
    "SETTING_ZULIP_ADMINISTRATOR" = var.zulip_administrator_email
    "SETTING_ADMIN_DOMAIN"        = var.zulip_admin_domain
  }
}

# Server Wiki Web App
resource "azurerm_app_service" "server_wiki_app" {
  name                = var.server_wiki_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|requarks/wiki:2"
    scm_type         = "None"
  }

  app_settings = {
    "WIKI_ADMIN_EMAIL"    = var.wiki_admin_email
    "WIKI_ADMIN_PASSWORD" = var.wiki_admin_password
    "DB_TYPE"             = "mysql"
    "DB_HOST"             = azurerm_mysql_server.mysql.fqdn
    "DB_PORT"             = 3306
    "DB_USER"             = azurerm_mysql_server.mysql.administrator_login
    "DB_PASS"             = azurerm_mysql_server.mysql.administrator_login_password
    "DB_NAME"             = azurerm_mysql_database.mysql_db.name
  }
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "sk-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "PublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.lb_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "vmBackendPool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "skvmBackendPool"
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
  name            = "zulip-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Server Wiki Web App Backend Pool
resource "azurerm_lb_backend_address_pool" "server_wiki_backend_pool" {
  name            = "server-wiki-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}