# Define the provider
provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"

  tags = {
    Name = "sk_rg"
  }
}

# Define the instances
resource "azurerm_linux_virtual_machine" "sk_vm" {
  name                  = "sk_vm"
  location              = azurerm_resource_group.sk_rg.location
  resource_group_name   = azurerm_resource_group.sk_rg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
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

  custom_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2 php mariadb-server php-mysql
              sudo /opt/lampp/lampp start
              sudo wget https://wordpress.org/latest.tar.gz
              sudo tar -xvzf latest.tar.gz -C /var/www/html/
              EOF

  tags = {
    Name = "sk_vm"
  }
}

# Define the network interface
resource "azurerm_network_interface" "sk_nic" {
  name                = "sk_nic"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  ip_configuration {
    name                          = "sk_nic_ipconfig"
    subnet_id                     = azurerm_subnet.sk_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name = "sk_nic"
  }
}

# Define the subnet
resource "azurerm_subnet" "sk_subnet" {
  name                 = "sk_subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  tags = {
    Name = "sk_subnet"
  }
}

# Define the virtual network
resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  tags = {
    Name = "sk_vnet"
  }
}

# Define the load balancer
resource "azurerm_lb" "sk_lb" {
  name                = "sk_lb"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  frontend_ip_configuration {
    name                          = "sk_lb_public_ip"
    public_ip_address_id          = azurerm_public_ip.sk_public_ip.id
  }

  backend_address_pool {
    name = "sk_lb_backend_pool"
  }

  probe {
    name                = "sk_lb_probe"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
    interval_in_seconds = 5
    number_of_probes    = 2
  }

  tags = {
    Name = "sk_lb"
  }
}

# Define the public IP address
resource "azurerm_public_ip" "sk_public_ip" {
  name                = "sk_public_ip"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  allocation_method   = "Static"

  tags = {
    Name = "sk_public_ip"
  }
}

# Define the load balancer rule
resource "azurerm_lb_rule" "sk_lb_rule" {
  name                   = "sk_lb_rule"
  resource_group_name    = azurerm_resource_group.sk_rg.name
  loadbalancer_id        = azurerm_lb.sk_lb.id
  protocol               = "Tcp"
  frontend_port          = 80
  backend_port           = 80
  backend_address_pool_id = azurerm_lb_backend_address_pool.sk_lb_backend_pool.id
}

# Define the load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "sk_lb_backend_pool" {
  name                = "sk_lb_backend_pool"
  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id     = azurerm_lb.sk_lb.id
}

# Define the monitoring
resource "azurerm_monitor_metric_alert" "sk_cpu_alert" {
  name                = "sk_cpu_alert"
  resource_group_name = azurerm_resource_group.sk_rg.name
  scopes              = [azurerm_linux_virtual_machine.sk_vm.id]
  description         = "This metric monitors CPU utilization"
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    time_grain       = "PT1M"
    dimension {
      name     = "Name"
      operator = "Include"
      values   = [azurerm_linux_virtual_machine.sk_vm.name]
    }
  }
  action {
    action_group_id = azurerm_action_group.sk_action_group.id
  }
}

# Define the action group
resource "azurerm_action_group" "sk_action_group" {
  name                = "sk_action_group"
  resource_group_name = azurerm_resource_group.sk_rg.name
  short_name          = "sk_action_group"
  email_receiver {
    name          = "sk_email_receiver"
    email_address = "admin@example.com"
  }
}