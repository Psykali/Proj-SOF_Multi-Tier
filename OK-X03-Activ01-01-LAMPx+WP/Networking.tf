## Networking
## Creat Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/8"]
  tags = local.common_tags
}

# Create Network Interface
resource "azurerm_network_interface" "default" {
  name = var.network_interface
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = local.common_tags
}
# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name                = var.ubuntu-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "sklampwp"
  tags = local.common_tags
}
# Create NSG
resource "azurerm_network_security_group" "default" {
  name = var.network_security_group_name
  location = var.location
  resource_group_name = var.resource_group_name

security_rule {
  name                   = "allow-http"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "80"
  source_address_prefix  = "*"
  destination_address_prefix= "*"
}

security_rule {
  name                   = "allow-https"
  priority               = 200
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "443"
  source_address_prefix  = "*"
  destination_address_prefix= "*"
}

security_rule {
    name                   = "allow-custom"
    priority               = 300
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "8080"
    source_address_prefix  = "*"
    destination_address_prefix= "*"
}

tags = local.common_tags

}

# Create Subnet
resource "azurerm_subnet" "default" {
  name                 = var.subnet
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
}