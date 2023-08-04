################
## Networking ##
################
# Creat Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/8"]
  tags = local.common_tags
}

# Create Subnet
resource "azurerm_subnet" "default" {
  name                 = var.subnet_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
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
###################
## Load Balancer ##
###################
resource "azurerm_public_ip" "default" {
  name                = "psykprjspip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "psykprjsp20"
}

resource "azurerm_lb" "default" {
  name                = "psykprjslb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "psykprjsfe"
    public_ip_address_id = azurerm_public_ip.default.id
  }
}

resource "azurerm_lb_backend_address_pool" "default" {
  loadbalancer_id = azurerm_lb.default.id
  name            = "psykprjspool"
}

resource "azurerm_network_interface_backend_address_pool_association" "admin_nic" {
  count                   = 3
  network_interface_id    = azurerm_network_interface.admin_nic[count.index].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}

resource "azurerm_network_interface_backend_address_pool_association" "chattickting_nic" {
  network_interface_id    = azurerm_network_interface.chattickting_nic.id
  ip_configuration_name   = var.chattickting_ip
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}

resource "azurerm_network_interface_backend_address_pool_association" "gitlab_nic" {
  network_interface_id    = azurerm_network_interface.gitlab_nic.id
  ip_configuration_name   = var.gitlab_ip
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}

resource "azurerm_network_interface_backend_address_pool_association" "clearenceai_nic" {
  network_interface_id    = azurerm_network_interface.clearenceai_nic.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}

resource "azurerm_network_interface_backend_address_pool_association" "web_nic" {
  network_interface_id    = azurerm_network_interface.web_nic.id
  ip_configuration_name   = var.web_ip
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}

resource "azurerm_network_interface_backend_address_pool_association" "wiki_nic" {
  network_interface_id    = azurerm_network_interface.wiki_nic.id
  ip_configuration_name   = var.wiki_ip
  backend_address_pool_id = azurerm_lb_backend_address_pool.default.id
}