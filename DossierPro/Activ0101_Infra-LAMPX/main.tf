# Resource Group
resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

# Virtual Network
resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk_vnet"
  resource_group_name = azurerm_resource_group.sk_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "sk_subnet" {
  name                 = "sk_subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "sk_nsg" {
  name                = "sk_nsg"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
}

# Load Balancer
resource "azurerm_lb" "sk_lb" {
  name                = "sk_lb"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  sku                 = "Standard"
}

# Load Balancer Backend Pool
resource "azurerm_lb_backend_address_pool" "sk_lb_backend_pool" {
  name            = "sk_backend_pool"
  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id = azurerm_lb.sk_lb.id
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "sk_vm" {
  count                = 2
  name                 = "sk_vm${count.index + 1}"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  location             = azurerm_resource_group.sk_rg.location
  size                 = "Standard_D2s_v3"
  admin_username       = "adminuser"
  network_interface_ids = [azurerm_network_interface.sk_nic[count.index].id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# Network Interfaces
resource "azurerm_network_interface" "sk_nic" {
  count               = 2
  name                = "sk_nic${count.index + 1}"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location

  ip_configuration {
    name                          = "sk_ipconfig${count.index + 1}"
    subnet_id                     = azurerm_subnet.sk_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.sk_vnet,
    azurerm_subnet.sk_subnet
  ]
}

# Network Security Group Rule (Allow HTTP and HTTPS)
resource "azurerm_network_security_rule" "sk_http" {
  name                        = "sk_allow_http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sk_rg.name
  network_security_group_name = azurerm_network_security_group.sk_nsg.name
}

# Database
resource "azurerm_mariadb_server" "sk_db" {
  name                = "sk_db"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  admin_username      = "adminuser"
  admin_password      = "YourPassword123!" # Replace with your desired password
  sku_name            = "B_Gen5_1"
  storage_auto_grow   = "Enabled"
  backup_retention_days = 7
}

# Public IP Address
resource "azurerm_public_ip" "sk_public_ip" {
  name                = "sk_public_ip"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  allocation_method   = "Static"
}

# Monitoring
resource "azurerm_monitor_diagnostic_setting" "sk_monitoring" {
  name               = "sk_diagnostic_setting"
  target_resource_id = azurerm_linux_virtual_machine.sk_vm[0].id
  log_analytics_workspace_id = "<your_log_analytics_workspace_id>"  # Replace with your Log Analytics workspace ID
  log {
    category = "System"
    enabled  = true
  }
}

# Output the Public IP Address
output "public_ip_address" {
  value = azurerm_public_ip.sk_public_ip.ip_address
}