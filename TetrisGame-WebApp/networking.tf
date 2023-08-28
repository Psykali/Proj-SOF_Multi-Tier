resource "azurerm_virtual_network" "example" {
  name                = "tetris-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet {
    name           = "example-subnet"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_virtual_network.example.subnet.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "http-rule"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "https-rule"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = "example-backend-pool"
  }

  probe {
    name                      = "example-probe"
    protocol                  = "Http"
    request_path              = "/"
    port                      = 80
    interval_seconds          = 30
    number_of_probes          = 2
    load_balancing_rule_ids   = [azurerm_lb_rule.example.http.id, azurerm_lb_rule.example.https.id]
    protocol_match_value      = "200-399"
    protocol_match_criteria   = "StatusCodes"
  }
}

resource "azurerm_lb_rule" "example" {
  count                     = 2
  name                      = count.index == 0 ? "http" : "https"
  protocol                  = count.index == 0 ? "Tcp" : "Https"
  frontend_port             = count.index == 0 ? 80 : 443
  backend_port              = 80
  frontend_ip_configuration = azurerm_lb.example.frontend_ip_configuration[0].id
  backend_address_pool_id   = azurerm_lb.example.backend_address_pool.id
  probe_id                  = azurerm_lb.example.probe.id
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  count                     = 3
  name                      = "example-webapp-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id       = azurerm_app_service_plan.example.id
  enabled                   = true
  https_only                = true
  site_config {
    linux_fx_version        = "DOCKER|skP20ContReg.azurecr.io/tetrisgameapp:602"
  }

  site_config {
    always_on = true
  }

  site_config {
    http2_enabled = true
  }

  site_config {
    websockets_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

}