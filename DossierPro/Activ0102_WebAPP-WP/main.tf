# Define the Azure provider
provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "skrg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

# Define the MariaDB server
resource "azurerm_mariadb_server" "skdb" {
  name                = "skdb"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku_name            = "B_Gen5_1"
  storage_profile {
    storage_mb        = 51200
    backup_retention_days = 7
    geo_redundant_backup_enabled = false
  }
  administrator_login          = "skadmin"
  administrator_login_password = "P@ssw0rd1234"
  version                       = "10.4"
}

# Define the WebApp for development
resource "azurerm_app_service_plan" "skdev_asp" {
  name                = "skdev-asp"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "skdev_webapp" {
  name                = "skdev-webapp"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  app_service_plan_id = azurerm_app_service_plan.skdev_asp.id
  site_config {
    always_on = true
  }
}

# Define the WebApp for production
resource "azurerm_app_service_plan" "skprod_asp" {
  name                = "skprod-asp"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "skprod_webapp" {
  name                = "skprod-webapp"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  app_service_plan_id = azurerm_app_service_plan.skprod_asp.id
  site_config {
    always_on = true
  }
}

# Define the storage account for media files
resource "azurerm_storage_account" "skstorage" {
  name                     = "skstorage"
  location                 = azurerm_resource_group.skrg.location
  resource_group_name      = azurerm_resource_group.skrg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Define the WorkBooks for monitoring
resource "azurerm_monitor_log_profile" "sklog" {
  name                = "sklog"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  categories          = ["Write", "Delete", "Action"]
}

resource "azurerm_monitor_diagnostic_setting" "skdiag" {
  name                = "skdiag"
  target_resource_id  = azurerm_app_service.skdev_webapp.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.skwork.id
  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_log_analytics_workspace" "skwork" {
  name                = "skwork"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Deploy WordPress on the WebApps
resource "azurerm_template_deployment" "skwp_dev" {
  name                = "skwp-dev"
  resource_group_name = azurerm_resource_group.skrg.name
  template_body       = file("${path.module}/wordpress.json")
  parameters = {
    "appServiceName"     = azurerm_app_service.skdev_webapp.name
    "mysqlServerName"    = azurerm_mariadb_server.skdb.name
    "mysqlUsername"      = azurerm_mariadb_server.skdb.administrator_login
    "mysqlPassword"      = azurerm_mariadb_server.skdb.administrator_login_password
    "mysqlDatabaseName"  = "wordpress"
    "storageAccountName" = azurerm_storage_account.skstorage.name
  }
}

resource "azurerm_template_deployment" "skwp_prod" {
  name                = "skwp-prod"
  resource_group_name = azurerm_resource_group.skrg.name
  template_body       = file("${path.module}/wordpress.json")
  parameters = {
    "appServiceName"     = azurerm_app_service.skprod_webapp.name
    "mysqlServerName"    = azurerm_mariadb_server.skdb.name
    "mysqlUsername"      = azurerm_mariadb_server.skdb.administrator_login
    "mysqlPassword"      = azurerm_mariadb_server.skdb.administrator_login_password
    "mysqlDatabaseName"  = "wordpress"
    "storageAccountName" = azurerm_storage_account.skstorage.name
  }
}

# Configure security
resource "azurerm_mariadb_firewall_rule" "skdb_fw" {
  name                = "skdb-fw"
  resource_group_name = azurerm_resource_group.skrg.name
  server_name         = azurerm_mariadb_server.skdb.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_app_service_certificate" "skssl" {
  name                = "skssl"
  resource_group_name = azurerm_resource_group.skrg.name
  location            = azurerm_resource_group.skrg.location
  hostname            = azurerm_app_service.skprod_webapp.default_site_hostname
  pfx_blob            = filebase64("${path.module}/skssl.pfx")
  password            = "P@ssw0rd1234!"
}

resource "azurerm_app_service_custom_hostname_binding" "skprod_binding" {
  name                = "skprod-binding"
  hostname            = "hackeuse.com"
  ssl_certificate_id  = azurerm_app_service_certificate.skssl.id
  app_service_name    = azurerm_app_service.skprod_webapp.name
  resource_group_name = azurerm_resource_group.skrg.name
}

# Set up backup and recovery
resource "azurerm_backup_policy_mariadb" "skdb_policy" {
  name                = "skdb-policy"
  resource_group_name = azurerm_resource_group.skrg.name
  server_name         = azurerm_mariadb_server.skdb.name
  backup_policy {
    type = "Automated"
    retention_days = 7
    time = "23:00"
  }
}

resource "azurerm_backup_schedule_mariadb" "skdb_schedule" {
  name                = "skdb-schedule"
  resource_group_name = azurerm_resource_group.skrg.name
  server_name         = azurerm_mariadb_server.skdb.name
  backup_schedule {
    type = "Full"
    frequency = "Weekly"
    retention_weeks = 4
    start_time = "23:00"
  }
}