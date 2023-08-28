resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "example" {
  count               = 2
  name                = "example-app-service${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version = "DOCKER|skP20ContReg.azurecr.io/tetrisgameapp"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "example" {
  name                = "example-appgateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "example-gateway-ip-configuration"
    subnet_id = azurerm_subnet.example.id
  }

  frontend_port {
    name = "example-frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "example-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name         = "example-backend-address-pool"
    ip_addresses = [azurerm_app_service.example[0].default_site_hostname, azurerm_app_service.example[1].default_site_hostname]
  }

  backend_http_settings {
    name                  = "example-backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

http_listener {
    name                           = "example-http-listener"
    frontend_ip_configuration_name = "example-frontend-ip-configuration"
    frontend_port_name             = "example-frontend-port"
    protocol                       = "Http"
 }
request_routing_rule {
    name                       = "example-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "example-http-listener"
    backend_address_pool_name  = "example-backend-address-pool"
    backend_http_settings_name = "example-backend-http-settings"
  }
}
#resource "azurerm_application_gateway_request_routing_rule" "example" {
#    name                       = "example-request-routing-rule"
#    rule_type                  = "Basic"
#    http_listener_name         = "example-http-listener"
#    backend_address_pool_name  = "example-backend-address-pool"
#    backend_http_settings_name = "example-backend-http-settings"
#}