# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

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

  custom_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y apache2 php mysql-server php-mysql

# Install Application Insights extension
wget -O /tmp/ApplicationInsightsExtension-1.1.0.tar.gz https://github.com/microsoft/ApplicationInsights-Home/releases/download/1.1.0/ApplicationInsightsExtension-1.1.0.tar.gz
tar -xvf /tmp/ApplicationInsightsExtension-1.1.0.tar.gz -C /tmp
/tmp/AiAgentLinux/install.sh -y --install-location /opt/microsoft/
/opt/microsoft/ApplicationInsights/monitors/Linux/AI-Agent-Linux.py --install

# Configure Application Insights
sed -i "s/InstrumentationKey=.*$/InstrumentationKey=${var.app_insights_instrumentation_key}/g" /etc/opt/microsoft/omsagent/conf/omsagent.conf
/opt/microsoft/omsagent/bin/service_control restart ApplicationInsights
EOF
}

# Create Application Insights
resource "azurerm_application_insights" "ai" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
}

# Output the public IP address
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}