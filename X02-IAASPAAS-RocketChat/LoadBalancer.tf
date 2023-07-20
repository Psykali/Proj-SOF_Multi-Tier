# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "sk-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "PublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.lb_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "vmBackendPool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "skvmBackendPool"
}

# Public IP Address
resource "azurerm_public_ip" "lb_ip" {
  name                = "my-lb-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

# Zulip Web App Backend Pool
resource "azurerm_lb_backend_address_pool" "zulip_backend_pool" {
  name            = "zulip-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Server Wiki Web App Backend Pool
resource "azurerm_lb_backend_address_pool" "server_wiki_backend_pool" {
  name            = "server-wiki-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}