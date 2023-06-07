provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "skrg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_virtual_network" "skvn" {
  name                = "skvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
}

resource "azurerm_subnet" "sksub" {
  name                 = "sksub"
  resource_group_name  = azurerm_resource_group.skrg.name
  virtual_network_name = azurerm_virtual_network.skvn.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "skni" {
  name                = "skni"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name

  ip_configuration {
    name                          = "sknicfg"
    subnet_id                     = azurerm_subnet.sksub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_storage_account" "sksa" {
  name                     = "sksa"
  resource_group_name      = azurerm_resource_group.skrg.name
  location                 = azurerm_resource_group.skrg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_mysql_server" "skmysql" {
  name                = "skmysql"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku_name            = "B_Gen5_1"
  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup_enabled = true
  }
  administrator_login          = "skadmin"
  administrator_login_password = "SuperSecretPassword123!"
  version                       = "5.7"
}

resource "azurerm_app_service_plan" "skasp" {
  name                = "skasp"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "sksite1" {
  name                = "sksite1"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  app_service_plan_id = azurerm_app_service_plan.skasp.id

  site_config {
    dotnet_framework_version = "v5.0"
    scm_type                 = "LocalGit"
  }
}

resource "azurerm_app_service" "sksite2" {
  name                = "sksite2"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  app_service_plan_id = azurerm_app_service_plan.skasp.id

  site_config {
    dotnet_framework_version = "v5.0"
    scm_type                 = "LocalGit"
  }
}

resource "azurerm_lb" "sklb" {
  name                = "sklb"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name

  frontend_ip_configuration {
    name                          = "sklbip"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.sksub.id
  }
}

resource "azurerm_lb_rule" "sklbrule" {
  name                  = "sklbrule"
  resource_group_name   = azurerm_resource_group.skrg.name
  loadbalancer_id       = azurerm_lb.sklb.id
  protocol              = "Tcp"
  frontend_port         = 80
  backend_port          = 80
  backend_address_pool_id = "${azurerm_app_service.sksite1.app_service_plan_id}"
}

resource "azurerm_lb_rule" "sklbrule2" {
  name                  = "sklbrule2"
  resource_group_name   = azurerm_resource_group.skrg.name
  loadbalancer_id       = azurerm_lb.sklb.id
  protocol              = "Tcp"
  frontend_port         = 80
  backend_port          = 80
  backend_address_pool_id = "${azurerm_app_service.sksite2.app_service_plan_id}"
}

resource "azurerm_monitor_diagnostic_setting" "skdiag" {
  name               = "skdiag"
  target_resource_id = azurerm_mysql_server.skmysql.id

  log {
    category = "MySqlSlowLogs"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_application_insights" "skai" {
  name                = "skai"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
}

resource "azurerm_storage_container" "skblob" {
  name                  = "skblob"
  resource_group_name   = azurerm_resource_group.skrg.name
  storage_account_name  = azurerm_storage_account.sksa.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "skra" {
  scope              = azurerm_resource_group.skrg.id
  role_definition_id = data.azurerm_role_definition.owner.id
  principal_id       = azurerm_ad_service_principal.sksp.id
}

data "azurerm_role_definition" "owner" {
  name = "Owner"
}

resource "azurerm_recovery_services_vault" "skrv" {
  name                = "skrv"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  sku                 = "Standard"
}

resource "azurerm_recovery_services_protection_policy_vm" "skpp" {
  name                = "skpp"
  resource_group_name = azurerm_resource_group.skrg.name
  backup_type         = "Full"
  retention_daily     = 30
  retention_weekly    = 4
  retention_monthly   = 12
  retention_yearly    = 99
}

resource "azurerm_recovery_services_protection_container" "skpc" {
  name                = "skpc"
  resource_group_name = azurerm_resource_group.skrg.name
  storage_account_id  = azurerm_storage_account.sksa.id
}

resource "azurerm_recovery_services_protection_policy_association" "skppa" {
  name                            = "skppa"
  recovery_services_vault_id      = azurerm_recovery_services_vault.skrv.id
  resource_group_name             = azurerm_resource_group.skrg.name
  source_vm_id                    = azurerm_virtual_machine.skvm.id
  backup_policy_id                = azurerm_recovery_services_protection_policy_vm.skpp.id
  recovery_services_protection_container_id = azurerm_recovery_services_protection_container.skpc.id
}

resource "azurerm_virtual_machine" "skvm" {
  name                  = "skvm"
  location              = azurerm_resource_group.skrg.location
  resource_group_name   = azurerm_resource_group.skrg.name
  vm_size               = "Standard_B2s"
  network_interface_ids = [azurerm_network_interface.skni.id]
}

output "skvn_id" {
  value = azurerm_virtual_network.skvn.id
}

output "sksubnet_id" {
  value = azurerm_subnet.sksub.id
}

output "skni_id" {
  value = azurerm_network_interface.skni.id
}

output "sksa_id" {
  value = azurerm_storage_account.sksa.id
}

output "skmysql_id" {
  value = azurerm_mysql_server.skmysql.id
}

output "skasp_id" {
  value = azurerm_app_service_plan.skasp.id
}

output "sksite1_id" {
  value = azurerm_app_service.sksite1.id
}

output "sksite2_id" {
  value = azurerm_app_service.sksite2.id
}

output "sklb_id" {
  value = azurerm_lb.sklb.id
}

output "skai_id" {
  value = azurerm_application_insights.skai.id
}

output "skdiag_id" {
  value = azurerm_monitor_diagnostic_setting.skdiag.id
}

output "skblob_id" {
  value = azurerm_storage_container.skblob.id
}

output "skrv_id" {
  value = azurerm_recovery_services_vault.skrv.id
}

output "skpp_id" {
  value = azurerm_recovery_services_protection_policy_vm.skpp.id
}

output "skpc_id" {
  value = azurerm_recovery_services_protection_container.skpc.id
}

output "skvm_id" {
  value = azurerm_virtual_machine.skvm.id
}