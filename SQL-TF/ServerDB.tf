###########################
## Create the SQL Server ##
###########################
resource "azurerm_sql_server" "example" {
  name                         = "multiwebsqlserv"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

##############################
## Create the SQL database ##
##############################
resource "azurerm_sql_database" "example" {
  name                = "q2astaging"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.example.name
}
##############################
## Create the SQL database ##
##############################
resource "azurerm_sql_database" "example" {
  name                = "q2aprd"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.example.name
}