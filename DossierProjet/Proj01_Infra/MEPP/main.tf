terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "${var.azurerm_version}"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "skprj01_rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

resource "azurerm_virtual_network" "skprj01_vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"
  address_space       = "${var.virtual_network_address_space}"
}

resource "azurerm_subnet" "skprj01_subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_resource_group.skprj01_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.skprj01_vnet.name}"
  address_prefixes     = "${var.subnet_address_prefixes}"
}

module "mariadb_vm" {
  source              = "Azure/compute/azurerm"
  version             = "1.2.0"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"
  vm_os_simple        = "${var.mariadb_vm_os_simple}"
  public_ip_dns       = ["${var.mariadb_vm_public_ip_dns}"]
  vnet_subnet_id      = "${azurerm_subnet.skprj01_subnet.id}"
}

resource "azurerm_lb" "skprj01_lb" {
  name                = "${var.load_balancer_name}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.skprj01_pip.id}"
  }
}

resource "azurerm_public_ip" "skprj01_pip" {
  name                = "${var.public_ip_name}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"
  allocation_method   = "${var.public_ip_allocation_method}"
}

resource "azurerm_lb_backend_address_pool" "skprj01_backend_pool" {
  name                = "skprj01_backend_pool"
  loadbalancer_id     = "${azurerm_lb.skprj01_lb.id}"
}

resource "azurerm_app_service_plan" "skprj01_asp" {
  name                = "${var.app_service_plan_name}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"

  sku {
    tier ="${var.app_service_plan_sku_tier}"
    size = "${var.app_service_plan_sku_size}"
  }
}

resource "azurerm_app_service" "skprj01_webapp" {
  count               = "${var.app_service_count}"
  name                = "skprj01_webapp_${count.index}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.skprj01_asp.id}"

  site_config {
    always_on = true
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.skprj01_ai.instrumentation_key}"
  }

  connection_string {
    name  = "mariadb_connection"
    type  = "MySQL"
    value = "Server=${module.mariadb_vm.vm_public_ip};Database=mydb;Uid=myuser;Pwd=mypassword;"
  }
}

resource "azurerm_storage_account" "skprj01_sa" {
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.skprj01_rg.name}"
  location                 = "${azurerm_resource_group.skprj01_rg.location}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_account_replication_type}"
}

resource "azurerm_application_insights" "skprj01_ai" {
  name                = "${var.application_insights_name}"
  location            = "${azurerm_resource_group.skprj01_rg.location}"
  resource_group_name = "${azurerm_resource_group.skprj01_rg.name}"
  application_type    = "${var.application_insights_type}"
}