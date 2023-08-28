#########################
## Create LoadBalancer ##
#########################
resource "azurerm_lb" "example" {
  name                = "tetris-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "TetrisPIPAddrs"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "TetrisBckEndAddrsPl"
}

