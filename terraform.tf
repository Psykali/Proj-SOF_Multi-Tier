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

resource "azurerm_scheduler_job_collection" "example" {
  name                = "persosiefjob"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Free"
  depends_on = [
    azurerm_web_app.example,
    azurerm_function_app.example,
    azurerm_storage_account.example
  ]
}

resource "azurerm_scheduler_job" "example" {
  name                            = "persosiefjob"
  job_collection_name             = azurerm_scheduler_job_collection.example.name
  resource_group_name             = azurerm_resource_group.example.name
  action {
    request {
      uri                   = "https://management.azure.com/subscriptions/${data.azurerm_subscription.example.id}/resourceGroups/${azurerm_resource_group.example.name}/providers/Microsoft.Web/sites/${azurerm_web_app.example.name}?api-version=2018-02-01"
      headers {
        "Content-Length" = "0"
      }
      method = "DELETE"
    }
  }
  recurrence {
    frequency = "Hour"
    interval  = 12
    start_time = "23:00"
    end_time = "23:05"
  }
  recurrence {
    frequency = "Hour"
    interval  = 12
    start_time = "08:00"
    end_time = "08:05"
  }
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
