###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
### Create the SQL Server
##resource "azurerm_sql_server" "sql_server" {
##  name                         = var.sql_server_name
##  location                     = var.location
##  resource_group_name          = var.resource_group_name
##  version                      = "12.0"
##  administrator_login          = var.admin_username
##  administrator_login_password = var.admin_password
##}
##############################################################
### Create firewall rule for SQL Server
##resource "azurerm_sql_firewall_rule" "sql_firewall_rule" {
##  name                = "AllowAll"
##  resource_group_name = var.resource_group_name
##  server_name         = azurerm_sql_server.sql_server.name
##  start_ip_address    = "0.0.0.0"
##  end_ip_address      = "255.255.255.255"
##}
##############################################################
### Create SQL Database
##resource "azurerm_sql_database" "sql_database" {
##  name                = var.sql_database_name
##  location            = var.location
##  resource_group_name = var.resource_group_name
##  server_name         = azurerm_sql_server.sql_server.name
##  edition             = "GeneralPurpose"
##  requested_service_objective_name = "GP_Gen5_2"
##}
###############################################################
# Create the Azure Container Instance
resource "azurerm_container_group" "aci" {
  name                = var.container_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = "${var.container_name}-dns"
  os_type             = "Linux"

  container {
    name   = var.container_name
    image  = var.image_name
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}