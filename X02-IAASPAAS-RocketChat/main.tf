###########################################
## Create Resource Group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################
# App Service Plan
resource "azurerm_app_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}
