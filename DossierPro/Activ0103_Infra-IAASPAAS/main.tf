##Resource Group
resource "azurerm_resource_group" "rg" {
name = "PERSO_SIEF"
location = "North Europe"
}

##Virtual Network
resource "azurerm_virtual_network" "vnet" {
name = "sk-vnet"
address_space = ["10.0.0.0/16"]
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
}

##Subnet
resource "azurerm_subnet" "subnet" {
name = "sk-subnet"
address_prefixes = ["10.0.1.0/24"]
virtual_network_name = azurerm_virtual_network.vnet.name
resource_group_name = azurerm_resource_group.rg.name
}

##Public IP Address
resource "azurerm_public_ip" "public_ip" {
name = "sk-public-ip"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name
allocation_method = "Static"
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "sk-backend-pool"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb" "lb" {
  name                = "sk-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend_pool.id
  ]
}

##Load Balancer
resource "azurerm_lb" "lb" {
name = "sk-lb"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name

frontend_ip_configuration {
name = "PublicIPAddress"
public_ip_address_id = azurerm_public_ip.public_ip.id
}

backend_address_pool {
name = "sk-backend-pool"
}
}

##Load Balancer Health Probe
resource "azurerm_lb_probe" "probe" {
name = "sk-probe"
protocol = "tcp"
port = 3306
interval_in_seconds = 5
number_of_probes = 2
loadbalancer_id = azurerm_lb.lb.id
}

##Load Balancer Rule
resource "azurerm_lb_rule" "rule" {
name = "sk-rule"
protocol = "tcp"
frontend_port = 3306
backend_port = 3306
frontend_ip_configuration_id = azurerm_lb.lb.frontend_ip_configuration[0].id
backend_address_pool_id = azurerm_lb.lb.backend_address_pool[0].id
probe_id = azurerm_lb_probe.probe.id
}

##Network Interface
resource "azurerm_network_interface" "nic" {
name = "sk-nic"
location = azurerm_resource_group.rg.location
resource_group_name = azurerm_resource_group.rg.name

ip_configuration {
name = "sk-ipconfig"
subnet_id = azurerm_subnet.subnet.id
private_ip_address_allocation = "Dynamic"
}
}

resource "azurerm_linux_virtual_machine" "mariadb_vm" {
  name                          = "sk-mariadb-vm"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  size                          = "Standard_B2s"
  admin_username                = "adminuser"
  disable_password_authentication = false

  os_profile {
    computer_name  = "sk-mariadb-vm"
    admin_username = "adminuser"
    admin_password = "your_admin_password"
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

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
}