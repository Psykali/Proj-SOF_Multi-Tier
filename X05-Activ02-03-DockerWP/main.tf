# Create the SQL Server
resource "azurerm_sql_server" "sql_server" {
  name                         = var.sql_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
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

# Create the Azure Container Instance
resource "azurerm_container_group" "aci" {
  name                = "wordpress-aci"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "public"
  dns_name_label      = "wordpress-aci-dns"
  os_type             = "Linux"

