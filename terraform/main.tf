terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.29.1"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {} 
}


#########################
##Create Resource Group##
#########################
resource "azurerm_resource_group" "G10B12_GrittyRazors_SK" {
  name     = "PERSO_SIEF"
  location = "West Europe"
}
##########################
##Create Storage account##
##########################
resource "azurerm_storage_account" "G10B12_GrittyRazors_SK" {
  resource_group_name      = azurerm_resource_group.G10B12_GrittyRazors_SK.name
  name                  = "persosiefsa"
  location                 = azurerm_resource_group.G10B12_GrittyRazors_SK.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
##Create storage account container
resource "azurerm_storage_container" "G10B12_GrittyRazors_SK" {
  name                  = "persosiefb"
  storage_account_name  = azurerm_storage_account.G10B12_GrittyRazors_SK.name
  container_access_type = "blob"
}
##########################################
##Create Application Insights for WebAPP##
##########################################
#resource "azurerm_application_insights" "G10B12_GrittyRazors_SK" {
#  name                = "G10-B12-SK-appinsight"
#  location            = azurerm_resource_group.G10B12_GrittyRazors_SK.location
#  resource_group_name = azurerm_resource_group.G10B12_GrittyRazors_SK.name
#  application_type    = "web"
#}
########################
##Create Service plan ##
########################
resource "azurerm_service_plan" "G10B12_GrittyRazors_SK" {
  name                = "perso-sief-splan"
  location            = azurerm_resource_group.G10B12_GrittyRazors_SK.location
  resource_group_name = azurerm_resource_group.G10B12_GrittyRazors_SK.name
  os_type             = "Linux"
#  os_type             = "Windows"
  sku_name            = "P1v2"
}
#######################
##Create Function App##
#######################
resource "azurerm_linux_function_app" "G10B12_GrittyRazors_SK" {
  name                       = "perso-sief-FunApp"
  location                   = azurerm_resource_group.G10B12_GrittyRazors_SK.location
  resource_group_name        = azurerm_resource_group.G10B12_GrittyRazors_SK.name
  service_plan_id            = azurerm_service_plan.G10B12_GrittyRazors_SK.id
  storage_account_name       = azurerm_storage_account.G10B12_GrittyRazors_SK.name
  storage_account_access_key = azurerm_storage_account.G10B12_GrittyRazors_SK.primary_access_key

site_config {
    always_on = true
    application_stack {
      dotnet_version = "6.0"
    }
  }
  app_settings = { 
  }

}
##Create Function App slot-Dev
resource "azurerm_linux_function_app_slot" "G10B12_GrittyRazors_SK" {
  name                       = "dev"
  function_app_id            = azurerm_linux_function_app.G10B12_GrittyRazors_SK.id
  storage_account_name       = azurerm_storage_account.G10B12_GrittyRazors_SK.name

site_config {
    always_on = true
    application_stack {
      dotnet_version = "6.0"
    }
  }
   app_settings = {
   
  }
}
###################
##Create Web-App ##
###################
resource "azurerm_linux_web_app" "G10B12_GrittyRazors_SK" {
  name                = "Gperos-sief-webapp"
  location            = azurerm_resource_group.G10B12_GrittyRazors_SK.location
  resource_group_name = azurerm_resource_group.G10B12_GrittyRazors_SK.name
  service_plan_id     = azurerm_service_plan.G10B12_GrittyRazors_SK.id

site_config {
    always_on = true
    application_stack {
      dotnet_version = "6.0"
    }
  }
  app_settings = { 
    
  }
}

##Create Web-App slot-Dev
resource "azurerm_linux_web_app_slot" "G10B12_GrittyRazors_SK" {
  name                = "dev"
  app_service_id      = azurerm_linux_web_app.G10B12_GrittyRazors_SK.id

site_config {
    always_on = true
    application_stack {
      dotnet_version = "6.0"
    }
  }
   app_settings = {
   
  }
}