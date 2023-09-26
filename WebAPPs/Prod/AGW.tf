resource "azurerm_public_ip" "skprjs_public_ip" {
  name                = "sofpip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}


resource "azurerm_virtual_network" "skprjs_vnet" {
  name                = "sofvnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]

  tags = local.common_tags
}

resource "azurerm_subnet" "skprjs_subnet" {
  name                 = "prod"
  resource_group_name  = "PERSO_SIEF"
  virtual_network_name = azurerm_virtual_network.skprjs_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_application_gateway" "skprjs_appgw" {
  name                = "sofappgw"
  location            = var.location
  resource_group_name = var.resource_group_name
 
  backend_address_pool {
    name = "sofbknd"
  }

  sku {
  name = "Standard_v2"
  tier = "Standard_v2"
 }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.skprjs_subnet.id
  }
  frontend_port {
    name = "port_80"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "appGwPublicFrontendIpIPv4"
    public_ip_address_id = azurerm_public_ip.skprjs_public_ip.id
  }
  
  backend_http_settings {
    name                  = "sofbackhttp"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = 50
    probe_name            = "sof_health"
  }
  http_listener {
    name                   = "soflistener"
    frontend_ip_configuration_name = "appGwPublicFrontendIpIPv4"
    frontend_port_name     = "port_80"
    protocol               = "Http"
  }
  request_routing_rule {
    name                       = "sof_rule"
    rule_type                  = "Basic"
    http_listener_name         = "soflistener"
    backend_address_pool_name  = "sofbkend"
    backend_http_settings_name = "sofbckhttp"
    priority                   = 1
  }
  probe {
    name                = "sof_health"
    protocol            = "Http"
    host                = "sksofalt-1.azurewebsites.net"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  autoscale_configuration {
    min_capacity = 1
    max_capacity = 10
  }
  tags = local.common_tags
}