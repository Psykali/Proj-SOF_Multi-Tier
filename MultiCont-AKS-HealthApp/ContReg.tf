### Create Azure Container Registry
resource "azurerm_container_registry" "psykprojs" {
  name                = "psykprojs-acr"
  resource_group_name = var.resource_group_name
  location            = var.location_contreg
  sku                 = "Standard"
  admin_enabled       = true
  tags = {
    displayName          = "Container Registry"
    "container.registry" = "psykprojs-acr"
  }
}