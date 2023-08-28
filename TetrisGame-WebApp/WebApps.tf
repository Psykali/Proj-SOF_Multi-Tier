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
#####################
## Create App Plan ##
#####################
resource "azurerm_app_service_plan" "example" {
  name                = "tetris-asp"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
##################################
## Create Web App for WordPress ##
##################################
resource "azurerm_app_service" "example" {
  count               = 3
  name                = "tetris-app${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version = "DOCKER|<your_docker_image>"
  }
}

resource "azurerm_traffic_manager_profile" "example" {
  name                = "tetris-tmp"
  resource_group_name = var.resource_group_name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "example-dns"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_endpoint" "example" {
  count               = length(azurerm_app_service.example)
  name                = "example-endpoint${count.index}"
  resource_group_name = var.resource_group_name
  profile_name        = azurerm_traffic_manager_profile.example.name
  target_resource_id   = element(azurerm_app_service.example.*.id, count.index)
  type                 = "azureEndpoints"
}

