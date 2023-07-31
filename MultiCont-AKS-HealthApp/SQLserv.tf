### Create SQL Server
resource "azurerm_sql_server" "psykprojs" {
  name                         = "psykprojs-sqlserver"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}
### Create SQL DB
resource "azurerm_sql_database" "psykprojs" {
  name                = "psykprojs-mhcdb"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.psykprojs.name
  edition             = "Basic"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes      = 1073741824
}
### SQL FireWall Setting
resource "azurerm_sql_firewall_rule" "psykprojs" {
  name                = "psykprojs-AllowAllWindowsAzureIps"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.psykprojs.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}