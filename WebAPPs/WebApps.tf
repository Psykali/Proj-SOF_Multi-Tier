##########
## Tags ##
##########
locals {
  common_tags = {
    CreatedBy = "SK"
    Env       = "Prod"
    Why       = "DipP20"
  }
}
############################
## Create Ressource Group ##
############################
#resource "azurerm_resource_group" "example" {
#  name     = "PERSO_SIEF"
#  location = "France Central"
#}
###########################
## Create the SQL Server ##
###########################
resource "azurerm_sql_server" "sql_backend_pool" {
  name                         = "sqlserv"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

##############################
## Create the SQL databases ##
##############################
resource "azurerm_sql_database" "sql_backend_pool" {
  count               = 3
  name                = "sqldb-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sql_backend_pool.name
}

######################################
## Create the load balancer for SQL ##
######################################
resource "azurerm_lb" "sqldbbkndlb" {
  name                = "sqldbbkndlb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PrivateIPAddress"
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    subnet_id                     = azurerm_subnet.example.id
  }
}

####################################################################
## Add the SQL databases to the backend pool of the load balancer ##
####################################################################
resource "azurerm_lb_backend_address_pool_address" "sql_backend_pool" {
  count                     = length(azurerm_sql_database.sql_backend_pool)
  loadbalancer_id           = azurerm_lb.sqldbbkndlb.id
  backend_address_pool_name = azurerm_lb.sqldbbkndlb.backend_address_pool[0].name
  name                      = "sql_backend_pool-${count.index}"
  virtual_machine_id        = azurerm_sql_database.sql_backend_pool[count.index].id
}
#####################
## Create App Plan ##
#####################
resource "azurerm_app_service_plan" "example" {
  name                = "app-service-plan"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
##################################
## Create Web App for WordPress ##
##################################
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
################################################
## Create Public IP address for Load Balancer ##
################################################
resource "azurerm_public_ip" "lb_pip" {
  name                = "lb-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}
##################################
## Create Load Balancer WebApps ##
##################################
resource "azurerm_lb" "lb" {
  name                = "webapp-lb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  backend_address_pool {
    name = "BackendPool"
  }

  tags = local.common_tags
}
#######################################
## backend pool of the load balancer ##
#######################################
resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackendPool"
}
###############################################################
## Add the Web Apps to the backend pool of the load balancer ##
###############################################################
resource "azurerm_lb_backend_address_pool_address" "example" {
  loadbalancer_id         = azurerm_lb.lb.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  name                    = "wordpressbkndpl"
  virtual_machine_id      = azurerm_linux_virtual_machine.example.id
}
#######################
## Create Front Door ##
#######################
resource "azurerm_frontdoor" "frontdoor" {
  name                = "webapp-frontdoor"
  location            = var.location
  resource_group_name = var.resource_group_name

  routing_rule {
    name               = "webapp-routing-rule"
    frontend_endpoints = [azurerm_frontdoor_frontend_endpoint.frontend.id]
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    forwarding_configuration {
      backend_pool_name = azurerm_lb_backend_address_pool.backend_pool.name
      backend_protocol  = "Http"
      backend_host_header = azurerm_app_service.wordpress_primary.default_site_hostname
    }
  }

  frontend_endpoint {
    name                 = "webapp-frontend"
    host_name            = azurerm_public_ip.lb_pip.fqdn
    session_affinity_enabled = true
    session_affinity_ttl_seconds = 300
  }

  tags = local.common_tags
}
################################
## Create Front Door EndPoint ##
################################
resource "azurerm_frontdoor_frontend_endpoint" "frontend" {
  name                              = "webapp-frontend"
  front_door_name                   = azurerm_frontdoor.frontdoor.name
  resource_group_name               = var.resource_group_name
  host_name                         = azurerm_public_ip.lb_pip.fqdn
  session_affinity_enabled          = true
  session_affinity_ttl_seconds      = 300
}
