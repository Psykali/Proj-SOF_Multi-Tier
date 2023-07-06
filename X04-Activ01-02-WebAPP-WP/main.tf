variable "location" {
  default = "francecentral"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "admin_username" {
  default = "skwp_admin"
}

variable "admin_password" {
  default = "P@ssw0rd123"
}

variable "webapp_name" {
  default = "skwp_webapp"
}

variable "sql_server_name" {
  default = "skwp_sqlserver"
}

variable "sql_database_name" {
  default = "skwp_sqldb"
}

variable "storage_account_name" {
  default = "skwp_storage"
}

variable "container_name" {
  default = "skwp_blobcontainer"
}

variable "vm_name" {
  default = "skwp_linuxvm"
}
# Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
##
# Create the app service plan
resource "azurerm_app_service_plan" "asp" {
  name                = "${var.webapp_name}-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create the webapp
resource "azurerm_app_service" "webapp" {
  name                = var.webapp_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "PHP|7.4"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Server=tcp:${var.sql_server_name}.database.windows.net;Database=${var.sql_database_name};User ID=${var.admin_username}@${var.sql_server_name};Password=${var.admin_password};Encrypt=true;Connection Timeout=30;"
  }
}

# Create the SQL Server
resource "azurerm_sql_server" "sql_server" {
  name                         = var.sql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

# Create firewall rule for SQL Server
resource "azurerm_sql_firewall_rule" "sql_firewall_rule" {
  name                = "AllowAll"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Create SQL Database
resource "azurerm_sql_database" "sql_database" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.name
  edition             = "GeneralPurpose"
  family              = "Gen5"
  capacity            = 2
  zone_redundant      = false
}

# Create Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create Blob Container
resource "azurerm_storage_container" "blob_container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Create Linux VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    name = "${var.vm_name}-osdisk"
  }
}