###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = var.network_interface
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.ubuntu-ipconfig
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name                = var.ubuntu-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.ubuntu-vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
   custom_data = base64encode(<<EOF
#!/bin/bash

sudo apt-get update -y

sudo apt-get install -y mariadb-server

sudo systemctl start mariadb

sudo systemctl enable mariadb

# Create the skwp-sqldb database
mysql -u root -e "CREATE DATABASE skwp-sqldb;"

EOF
  )
}
