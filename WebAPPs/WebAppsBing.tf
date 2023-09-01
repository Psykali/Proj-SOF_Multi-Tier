resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "multiwebip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "example" {
  name                = "example-lb"
  resource_group_name = var.resource_group_name
  location            = var.location

  frontend_ip_configuration {
    name                 = "example-frontend-ip"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "webappbkend" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "webappbkend-pool"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "example-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "example-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.webappbkend.id]
}

resource "azurerm_app_service_plan" "example" {
    name                = "multiWeb-asp"
    resource_group_name = var.resource_group_name
    location            = var.location
    kind                = "Linux"
    reserved            = true

    sku {
        tier     = "Standard"
        size     = "S1"
    }
}

variable "app_names" {
    type    = list(string)
    default = ["1stwppsyckprjst", "2ndwppsyckprjs", "3rdwppsyckprjs"]
}
resource "azurerm_app_service" "webapp1" {
    count               = length(var.app_names)
    name                = var.app_names[count.index]
    location            = var.location
    resource_group_name = var.resource_group_name
    app_service_plan_id = azurerm_app_service_plan.example.id

    site_config {
        always_on       = true
        linux_fx_version= "DOCKER|wordpress:latest"
    }

    identity {
        type= "SystemAssigned"
    }

    tags= local.common_tags
    
      connection_string {
        name  = "Database"
        type  = "SQLAzure"
        value = "Server=tcp:${azurerm_sql_server.example.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.example.name};User ID=${var.admin_username};Password=${var.admin_password};"
    }
}

resource "azurerm_app_service_slot" "staging" {
  count               = length(var.app_names)
  name                ="staging"
  app_service_name    = azurerm_app_service.webapp1[count.index].name
  location            = azurerm_app_service.webapp1[count.index].location
  resource_group_name= azurerm_app_service.webapp1[count.index].resource_group_name
  app_service_plan_id= azurerm_app_service_plan.example.id

   connection_string {
        name   ="Database"
        type   ="SQLAzure"
        value ="Server=tcp:${azurerm_sql_server.example.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.example.name};User ID=${var.admin_username};Password=${var.admin_password};"
   }
}