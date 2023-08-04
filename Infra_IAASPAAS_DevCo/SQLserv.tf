# MySQL Server
resource "azurerm_mysql_server" "mysql" {
  name                = var.mysql_server_name
  location            = var.location
  resource_group_name = var.resource_group_name
  administrator_login = var.admin_username
  administrator_login_password = var.admin_password
  sku_name            = "B_Gen5_1"
  version             = "5.7"
  storage_mb          = 5120
  ssl_enforcement_enabled = true
}