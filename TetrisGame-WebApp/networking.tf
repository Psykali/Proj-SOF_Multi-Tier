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

resource "azurerm_traffic_manager_profile" "example" {
  name                   = "example-trafficmanagerprofile"
  resource_group_name = var.resource_group_name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "example-trafficmanagerprofile"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
    custom_header_host           = ""
    expected_status_code_ranges {
      min   = 200
      max   = 299
    }
  }
}

resource "azurerm_traffic_manager_endpoint" "example" {
  count              = 2
  name               = "example-endpoint${count.index + 1}"
  resource_group_name = var.resource_group_name
  profile_name       = azurerm_traffic_manager_profile.example.name
  target_resource_id = azurerm_app_service.example[count.index].id
}
