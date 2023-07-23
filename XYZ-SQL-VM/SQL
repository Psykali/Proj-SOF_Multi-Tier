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
