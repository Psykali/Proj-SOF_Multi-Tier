# Define the resource group
resource "azurerm_resource_group" "skrg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

# Define the MariaDB server
resource "azurerm_mariadb_server" "skdb" {
  name                         = "skwp-db"
  location                     = azurerm_resource_group.skrg.location
  resource_group_name          = azurerm_resource_group.skrg.name
  sku_name                     = "B_Gen5_1"
  storage_mb                   = 5120
  administrator_login          = var.db_admin_username
  administrator_login_password = var.db_admin_password
  version                      = "10.3"
  ssl_enforcement_enabled      = true
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
  locations           = [azurerm_resource_group.skrg.location]
  categories          = ["Write"]
  retention_policy {
    enabled = true
    days    = 30
  }
  resource_group_name = azurerm_resource_group.skrg.name
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
  name         = "skssl"
  resource_group_name = azurerm_resource_group.skrg.name
  location     = azurerm_resource_group.skrg.location
  host_names   = [azurerm_app_service.skprod_webapp.default_site_hostname]
  pfx_password = var.skssl_password
  pfx_blob     = filebase64("${path.module}/skssl.pfx")
}

resource "azurerm_app_service_custom_hostname_binding" "skprod_binding" {
  hostname             = azurerm_app_service_custom_domain.skprod_domain.hostname
  resource_group_name  = azurerm_resource_group.skrg.name
  app_service_name     = azurerm_app_service.skprod_webapp.name
  thumbprint           = azurerm_app_service_certificate.skssl.thumbprint
  ssl_state            = "SniEnabled"
  host_name_ssl_states = ["${azurerm_app_service.skprod_webapp.default_site_hostname} = \"SniEnabled\""]
}

# Set up backup and recovery
resource "azurerm_mariadb_database" "skdb" {
  name                = "skdb"
  resource_group_name = azurerm_resource_group.skrg.name
  server_name         = azurerm_mariadb_server.skdb_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"

  backup {
    retention_days = 7
    geo_redundant_backup_enabled = true
  }
}

resource "azurerm_backup_policy" "skdb_policy" {
  name                = "skdb-policy"
  resource_group_name = azurerm_resource_group.skrg.name

  rule {
    name = "DailyBackup"
    type = "Daily"
    time = "23:00"
    retention_daily {
      count = 7
    }
  }

  target {
    resource_id = azurerm_mariadb_database.skdb.id
  }
}