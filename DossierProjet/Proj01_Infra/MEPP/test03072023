# Define the provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk_virtual_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
}

resource "azurerm_subnet" "sk_web_subnet" {
  name                 = "sk_web_subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sk_mariadb_subnet" {
  name                 = "sk_mariadb_subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "sk_nsg" {
  name                = "sk_network_security_group"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "sk_mariadb_vm_nic" {
  name                = "sk_mariadb_vm_nic"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  ip_configuration {
    name                          = "sk_mariadb_vm_ipconfig"
    subnet_id                     = azurerm_subnet.sk_mariadb_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.10"
  }
}

resource "azurerm_linux_virtual_machine" "sk_mariadb_vm" {
  name                = "sk_mariadb_vm"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  size                = "Standard_D2_v2"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  network_interface_ids = [
    azurerm_network_interface.sk_mariadb_vm_nic.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_lb" "sk_web_lb" {
  name                = "sk_web_lb"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  frontend_ip_configuration {
    name                          = "sk_web_lb_frontend_ipconfig"
    subnet_id                     = azurerm_subnet.sk_web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name = "sk_web_lb_backend_pool"
  }

  probe {
    name                = "sk_web_lb_probe"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
    interval_in_seconds = 5
    number_of_probes    = 2
  }

  load_balancing_rule {
    name               = "sk_web_lb_rule"
    frontend_port      = 80
    backend_port       = 80
    protocol           = "Tcp"
    backend_address_pool_id = azurerm_lb_backend_address_pool.sk_web_lb_backend_pool.id
    probe_id           = azurerm_lb_probe.sk_web_lb_probe.id
  }
}

resource "azurerm_lb_backend_address_pool" "sk_web_lb_backend_pool" {
  name                = "sk_web_lb_backend_pool"
  load_balancer_id    = azurerm_lb.sk_web_lb.id
}

resource "azurerm_lb_probe" "sk_web_lb_probe" {
  name                = "sk_web_lb_probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
  load_balancer_id    = azurerm_lb.sk_web_lb.id
}

resource "azurerm_network_interface" "sk_web_app_nic_1" {
  name                = "sk_web_app_nic_1"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  ip_configuration {
    name                          = "sk_web_app_ipconfig_1"
    subnet_id                     = azurerm_subnet.sk_web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "sk_web_app_nic_2" {
  name                = "sk_web_app_nic_2"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  ip_configuration {
    name                          = "sk_web_app_ipconfig_2"
    subnet_id                     = azurerm_subnet.sk_web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_application_insights" "sk_app_insights" {
  name                = "sk_app_insights"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  application_type    = "web"
}

