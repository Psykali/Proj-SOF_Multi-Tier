################################
## Define the virtual network ##
################################
resource "azurerm_virtual_network" "vnet" {
  name                = "psykprojs-aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}
#######################
## Define the subnet ##
#######################
resource "azurerm_subnet" "aks" {
  name                 = "psykprojs-aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
##################################
## Define the public IP address ##
##################################
resource "azurerm_public_ip" "aks" {
  name                = "psykprojs-aks-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}
##################################
## Define the network interface ##
##################################
resource "azurerm_network_interface" "aks" {
  name                = "psykprojs-aks-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "aks-nic-ipconfig"
    subnet_id                     = azurerm_subnet.aks.id
    private_ip_address_allocation = "Dynamic"
  }
}