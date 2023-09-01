resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "example-frontend-ip"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "example-backend-pool"
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "example-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "example-frontend-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.example.id
}

resource "azurerm_app_service_plan" "example1" {
    name                ="example-asp"
    location            ="${azurerm_resource_group.example.location}"
    resource_group_name ="${azurerm_resource_group.example.name}"

    sku {
        tier     ="Standard"
        size     ="S1"
    }
}

resource "azurerm_app_service" "webapp1" {
variable "app_names" {
  type = list(string)
  default = ["1stwppsyckprjst", "2ndwppsyckprjs", "3rdwppsyckprjs"]
}
resource "azurerm_app_service" "wordpress" {
  count               = length(var.app_names)
  name                = var.app_names[count.index]
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true
    linux_fx_version = "DOCKER|wordpress:latest"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_app_service_slot" "example" {
  app_service_name       = azurerm_app_service.wordpress[0].name
  location               = azurerm_app_service.wordpress[0].location
  resource_group_name    = azurerm_app_service.wordpress[0].resource_group_name
  app_service_plan_id    = azurerm_app_service_plan.example.id
  name                   = "staging"

  connection_string {
    name  = "Database"
    type  = "SQLAzure"
    value = "Server=tcp:${azurerm_lb.sqldbbkndlb.private_ip_address},1433;Initial Catalog=sqldb-0;User ID=${var.admin_username};Password=${var.admin_password};"
  }
}
}
