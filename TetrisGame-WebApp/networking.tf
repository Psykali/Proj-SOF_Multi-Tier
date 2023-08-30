resource "azurerm_virtual_network" "example" {
  name                = "Tetris-apps-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}
########
resource "azurerm_subnet" "example" {
  name                 = "Tetris-apps-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}
########
resource "azurerm_public_ip" "example" {
  name                = "Tetris-apps-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method  = "Static"
}
########
resource "azurerm_app_service_plan" "example" {
  name                = "Tetris-apps-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  
  sku {
    tier = "Standard"
    size = "S1"
  }
}
########
resource "azurerm_app_service" "web_app" {
  count               = 2
  name                = "Tetris-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version = "DOCKER|skP20ContReg.azurecr.io/tetrisgameapp"
  }
}
########
resource "azurerm_application_gateway" "example" {
  name                = "web-apps-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    for_each = azurerm_app_service.web_app
    name     = "webapp-backend-pool-${each.key}"
    fqdns    = [each.value.default_site_hostname]
  }

  http_listener {
    for_each                      = azurerm_app_service.web_app
    name                          = "http-listener-${each.key}"
    frontend_ip_configuration_name = azurerm_application_gateway.example.frontend_ip_configuration[0].name
    frontend_port_name            = "http"
  }

  request_routing_rule {
    for_each               = azurerm_app_service.web_app
    name                   = "webapp-rule-${each.key}"
    rule_type              = "Basic"
    http_listener_name     = azurerm_application_gateway.example.http_listener[each.key].name
    backend_address_pool_name  = azurerm_application_gateway.example.backend_address_pool[each.key].name
    backend_http_settings_name = "appGatewayBackendHttpSettings"
  }
}