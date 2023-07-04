# Define the provider
provider "azurerm" {
  features {}
}


# Define the virtual network
resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
}

# Define the subnet
resource "azurerm_subnet" "sk_subnet" {
  name                 = "sk_subnet"
  resource_group_name  = "PERSO_SIEF"
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define the public IP address
resource "azurerm_public_ip" "sk_public_ip" {
  name                = "sk_public_ip"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  allocation_method   = "Static"
}

# Define the load balancer
resource "azurerm_lb" "sk_lb" {
  name                = "sk_lb"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  frontend_ip_configuration {
    name                          = "sk_lb_public_ip"
    public_ip_address_id          = azurerm_public_ip.sk_public_ip.id
  }
}

# Define the load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "sk_lb_backend_pool" {
  name                = "sk_lb_backend_pool"
  loadbalancer_id     = azurerm_lb.sk_lb.id
}

# Define the load balancer rule
resource "azurerm_lb_rule" "sk_lb_rule" {
  name                   = "sk_lb_rule"
  frontend_ip_configuration_name = azurerm_lb.sk_lb.frontend_ip_configuration[0].name
  loadbalancer_id        = azurerm_lb.sk_lb.id
  protocol               = "Tcp"
  frontend_port          = 80
  backend_port           = 80
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.sk_lb_backend_pool.id]
}

# Define the virtual machines
resource "azurerm_linux_virtual_machine" "sk_vm" {
  name                  = "skvm"
  location              = "francecentral"
  resource_group_name   = "PERSO_SIEF"
  size                  = "Standard_B1s"
  disable_password_authentication = false
  admin_username        = "skadminadminuser"
  admin_password        = "skadminadminlogpass"
  network_interface_ids = [azurerm_network_interface.sk_nic.id]

  os_disk {
    name              = "sk_vm_osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2 php mariadb-server php-mysql
              sudo /opt/lampp/lampp start
              sudo wget https://wordpress.org/latest.tar.gz
              sudo tar -xvzf latest.tar.gz -C /var/www/html/
              EOF
              )

  tags = {
    Name = "sk_vm"
  }
}

# Define the network interface
resource "azurerm_network_interface" "sk_nic" {
  name                = "sk_nic"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  ip_configuration {
    name                          = "sk_nic_ipconfig"
    subnet_id                     = azurerm_subnet.sk_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name = "sk_nic"
  }
}