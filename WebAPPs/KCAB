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
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true
    linux_fx_version = "DOCKER|psykali/stackoverp20kcab"
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
# Create a dev web app
resource "azurerm_app_service" "dev_webapp" {
  name                = "skskabdocker-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on = true
    linux_fx_version = "DOCKER|psykali/stackoverp20kcab"
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

