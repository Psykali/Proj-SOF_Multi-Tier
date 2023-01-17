resource "azurerm_resource_group" "example" {
  name     = "PERSO_SIEF"
  location = "West Europe"
}

resource "azurerm_web_app" "example" {
  name                = "persosiefwebapp"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  app_service_plan_id = azurerm_app_service_plan.example.id
}

resource "azurerm_function_app" "example" {
  name                      = "persosieffuncapp"
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  app_service_plan_id       = azurerm_app_service_plan.example.id
  storage_connection_string = azurerm_storage_account.example.primary_connection_string
}

resource "azurerm_app_service_plan" "example" {
  name                = "persosiefplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "persosiefstorage"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

terraform {
  backend "azurerm" {
    storage_account_name = azurerm_storage_account.example.name
    container_name       = azurerm_storage_container.example.name
    key                  = "state.tfstate"
  }
}
