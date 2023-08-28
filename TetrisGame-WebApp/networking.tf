#################
## Create Vnet ##
#################
resource "azurerm_virtual_network" "example" {
  name                = "tetris-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}
###################
## Create Subnet ##
###################
resource "azurerm_subnet" "example" {
  name                 = "tetris-subnet"
  resource_group_name  = var.location
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
######################
## Create Public IP ##
######################
resource "azurerm_public_ip" "example" {
  name                = "tetris-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}