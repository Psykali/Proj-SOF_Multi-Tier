terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "skprj01_rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_virtual_network" "skprj01_vnet" {
  name                = "skprj01_vnet"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "skprj01_subnet" {
  name                 = "skprj01_subnet"
  resource_group_name  = azurerm_resource_group.skprj01_rg.name
  virtual_network_name = azurerm_virtual_network.skprj01_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "mariadb_vm" {
  source              = "Azure/compute/azurerm"
  version             = "1.2.0"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["skprj01_mariadb_pip"]
  vnet_subnet_id      = azurerm_subnet.skprj01_subnet.id
}

resource "azurerm_lb" "skprj01_lb" {
  name                = "skprj01_lb"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.skprj01_pip.id
  }
}

resource "azurerm_public_ip" "skprj01_pip" {
  name                = "skprj01_pip"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb_backend_address_pool" "skprj01_backend_pool" {
  name                = "skprj01_backend_pool"
  loadbalancer_id     = azurerm_lb.skprj01_lb.id
}

resource "azurerm_app_service_plan" "skprj01_asp" {
  name                = "skprj01_asp"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "skprj01_webapp" {
  count               = 2
  name                = "skprj01_webapp_${count.index}"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name
  app_service_plan_id = azurerm_app_service_plan.skprj01_asp.id

  site_config {
    always_on = true
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.skprj01_ai.instrumentation_key
  }

  connection_string {
    name  = "mariadb_connection"
    type  = "MySQL"
    value = "Server=${module.mariadb_vm.vm_public_ip};Database=mydb;Uid=myuser;Pwd=mypassword;"
  }
}

resource "azurerm_storage_account" "skprj01_sa" {
  name                     = "skprj01sa"
  resource_group_name      = azurerm_resource_group.skprj01_rg.name
  location                 = azurerm_resource_group.skprj01_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_application_insights" "skprj01_ai" {
  name                = "skprj01_ai"
  location            = azurerm_resource_group.skprj01_rg.location
  resource_group_name = azurerm_resource_group.skprj01_rg.name
  application_type    = "web"
}