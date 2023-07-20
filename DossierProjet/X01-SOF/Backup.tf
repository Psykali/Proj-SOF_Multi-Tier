## Create Backup
resource "azurerm_recovery_services_vault" "recovery_vault" {
  name                = "skrv"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "skrvpolicy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.recovery_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 8
  }
}

resource "azurerm_backup_protected_vm" "protected_vm" {
  resource_group_name     = var.resource_group_name
  recovery_vault_name     = azurerm_recovery_services_vault.recovery_vault.name
  source_vm_id            = azurerm_linux_virtual_machine.vm.id
  backup_policy_id        = azurerm_backup_policy_vm.backup_policy.id
}