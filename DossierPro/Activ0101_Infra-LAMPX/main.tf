# Resource Group
resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
}

resource "azurerm_subnet" "sk_subnet" {
  name                 = "sk-subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_lb" "sk_lb" {
  name                = "sk-lb"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  sku                 = "Standard"
}

resource "azurerm_lb_backend_address_pool" "sk_lb_backend_pool" {
  name                = "sk-lb-backend-pool"
  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id     = azurerm_lb.sk_lb.id
}

resource "azurerm_mariadb_server" "sk_db" {
  name                = "sk-db"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  sku_name            = "B_Gen5_2"
  storage_mb          = 5120
  administrator_login = "adminuser"
  administrator_login_password = "YourPassword123!"
}

resource "azurerm_mariadb_database" "sk_db" {
  name                = "sk-db"
  resource_group_name = azurerm_resource_group.sk_rg.name
  server_name         = azurerm_mariadb_server.sk_db.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}