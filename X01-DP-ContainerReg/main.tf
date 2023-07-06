provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "acr" {
  name                = "skcontreg"
  resource_group_name = "PERSO_SIEF"
  location            = "francecentral"
  sku                 = "Premium"
  admin_enabled       = false

  replication {
    location                = "westeurope"
    zone_redundancy_enabled = true
  }

  replication {
    location                = "northeurope"
    zone_redundancy_enabled = true
  }

  tags = {
    environment = "production"
  }
}

resource "azurerm_container_registry_webhook" "wordpress_push" {
  name                = "wordpress-push-webhook"
  container_registry_id = azurerm_container_registry.acr.id
  service_uri         = "https://example.com/wordpress"
  actions {
    action = "push"
  }
  custom_headers = {
    "Authorization" = "Bearer ${var.authorization_token}"
  }
}

resource "azurerm_container_registry_webhook" "rocketchat_push" {
  name                = "rocketchat-push-webhook"
  container_registry_id = azurerm_container_registry.acr.id
  service_uri         = "https://example.com/rocketchat"
  actions {
    action = "push"
  }
  custom_headers = {
    "Authorization" = "Bearer ${var.authorization_token}"
  }
}

resource "azurerm_container_registry_scope_map" "example" {
  name                = "example-scope-map"
  container_registry_id = azurerm_container_registry.acr.id

  scope {
    name = "example-wordpress"
    actions = ["push", "pull"]
    type = "repository"
    repository = "wordpress/*"
  }

  scope {
    name = "example-rocketchat"
    actions = ["push", "pull"]
    type = "repository"
    repository = "rocketchat/*"
  }
}