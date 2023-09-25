################
## Networking ##
################
# Creat Vnet
#resource "azurerm_virtual_network" "vnet" {
#  name                = var.virtual_network_name
#  location            = var.location
#  resource_group_name = var.resource_group_name
#  address_space       = ["10.0.0.0/8"]
#  tags = local.common_tags
#}

# Create Subnet
resource "azurerm_subnet" "default" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
}