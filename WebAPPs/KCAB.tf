# Create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = "skskabstrg"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create an App Service plan
resource "azurerm_app_service_plan" "asp" {
  name                = "skskabdockersp"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  kind                = "linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

# Create a web app
resource "azurerm_app_service" "webapp" {
  name                = "skskabdocker-prd"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  app_service_plan_id  = azurerm_app_service_plan.asp.id
  site_config {
    linux_fx_version = "NODE|14-lts"
  }
}

# Create a dev web app
resource "azurerm_app_service" "dev_webapp" {
  name                = "skskabdocker-dev"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  app_service_plan_id  = azurerm_app_service_plan.asp.id
  site_config {
    linux_fx_version = "NODE|14-lts"
  }
}

# Link the web app to the container image
resource "azurerm_app_service" "container" {
  name                = azurerm_app_service.webapp.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  app_service_plan_id  = azurerm_app_service_plan.asp.id
  site_config {
    always_on       = true
    linux_fx_version = "DOCKER|psykali/stackoverp20kcab"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io"
  }
}
