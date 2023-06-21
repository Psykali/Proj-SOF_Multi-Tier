# Provider configuration
#provider "azurerm" {
#  features {}
#}
#
# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "PERSO_SIEF"
  location = "North Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "sk-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "sk-subnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

# Public IP Address
resource "azurerm_public_ip" "public_ip" {
  name                = "sk-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "sk-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = "sk-backend-pool"
  }
}

# Load Balancer Health Probe
resource "azurerm_lb_probe" "probe" {
  name                = "sk-probe"
  protocol            = "tcp"
  port                = 3306
  interval_in_seconds = 5
  number_of_probes    = 2
  load_balancer_id    = azurerm_lb.lb.id
}

# Load Balancer Rule
resource "azurerm_lb_rule" "rule" {
  name                     = "sk-rule"
  protocol                 = "tcp"
  frontend_port            = 3306
  backend_port             = 3306
  frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
  backend_address_pool_id = azurerm_lb.lb.backend_address_pool[0].id
  probe_id                 = azurerm_lb_probe.probe.id
}

# MariaDB Virtual Machine
resource "azurerm_linux_virtual_machine" "mariadb_vm" {
  name                = "sk-mariadb-vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name              = "sk-mariadb-vm-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "mariadb"
    offer     = "mariadb-10-4"
    sku       = "mariadb-10-4"
    version   = "latest"
  }

  custom_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y mariadb-server
    sudo mysql_secure_installation
    EOF
  )
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "sk-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "sk-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pool_ids = [
      azurerm_lb.lb.backend_address_pool[0].id
    ]
  }
}

# Front-end Web Application 1
resource "azurerm_linux_virtual_machine" "webserver1" {
  name                = "sk-webserver1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  disable_password_authentication = true
  network_interface_ids =[
    azurerm_network_interface.webserver1_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name              = "sk-webserver1-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    EOF
  )
}

# Network Interface for Front-end Web Application 1
resource "azurerm_network_interface" "webserver1_nic" {
  name                = "sk-webserver1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "sk-webserver1-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pool_ids = [
      azurerm_lb.lb.backend_address_pool[0].id
    ]
  }
}

# Front-end Web Application 2
resource "azurerm_linux_virtual_machine" "webserver2" {
  name                = "sk-webserver2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.webserver2_nic.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name              = "sk-webserver2-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(
    <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    EOF
  )
}

# Network Interface for Front-end Web Application 2
resource "azurerm_network_interface" "webserver2_nic" {
  name                = "sk-webserver2-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "sk-webserver2-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pool_ids = [
      azurerm_lb.lb.backend_address_pool[0].id
    ]
  }
}

# Application Insights
resource "azurerm_application_insights" "appinsights" {
  name                = "sk-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Storage Account
resource "azurerm_storage_account" "storageaccount" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Output
output "mariadb_vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "webserver1_public_ip" {
  value = azurerm_network_interface.webserver1_nic.private_ip_address
}

output "webserver2_public_ip" {
  value = azurerm_network_interface.webserver2_nic.private_ip_address
}