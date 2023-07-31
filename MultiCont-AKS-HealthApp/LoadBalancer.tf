### Create Load balancer
name                = "aks-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                  = "aks-lb-public-ip"
    public_ip_address_id  = azurerm_public_ip.aks.id
  }
}

### Define the load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "aks" {
  name            = "aks-lb-backend-pool"
  loadbalancer_id = azurerm_lb.aks.id
}

### Define the load balancer rule
resource "azurerm_lb_rule" "aks" {
  name                   = "aks-lb-rule"
  frontend_ip_configuration_name = azurerm_lb.aks.frontend_ip_configuration[0].name
  loadbalancer_id        = azurerm_lb.aks.id
  protocol               = "Tcp"
  frontend_port          = 80
  backend_port           = 80
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.aks.id]
}