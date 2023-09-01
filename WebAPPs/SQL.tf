###########################
## Create the SQL Server ##
###########################
resource "azurerm_sql_server" "sql_backend_pool" {
  name                         = "sqlserv"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}
##############################
## Create the SQL databases ##
##############################
resource "azurerm_sql_database" "sql_backend_pool" {
  count               = 3
  name                = "sqldb-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_backend_pool.name
}

######################################
## Create the load balancer for SQL ##
######################################
resource "azurerm_lb" "sqldbbkndlb" {
  name                = "sqldbbkndlb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = azurerm_subnet.example.id # Update this to reference an existing subnet resource
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.sqldbbkndlb.id
  name            = "example-backend-pool"
}

####################################################################
## Add the SQL databases to the backend pool of the load balancer ##
####################################################################
resource "azurerm_lb_backend_address_pool_address" "sql_backend_pool" {
  count                   = length(azurerm_sql_database.sql_backend_pool)
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id # Add this argument
  name                    = "sql_backend_pool-${count.index}"
  ip_address              = azurerm_sql_database.sql_backend_pool[count.index].id # Update this argument
}
