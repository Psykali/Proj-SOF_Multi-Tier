resource "azurerm_resource_group" "sk_rg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

resource "azurerm_public_ip" "sk_pip" {
  name                = "sk_pip"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  allocation_method = "Dynamic"
}
resource "azurerm_lb_frontend_ip_configuration" "sk_lb_fe" {
  name                 = "sk-lb-fe"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  loadbalancer_id      = azurerm_lb.sk_lb.id
  public_ip_address_id = azurerm_public_ip_address.sk_pip.id
}

resource "azurerm_lb" "sk_lb" {
  name                = "sk_lb"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  frontend_ip_configuration {
    name                 = "sk_lb_fe"
    public_ip_address_id = azurerm_public_ip.sk_pip.id
  }
}

resource "azurerm_availability_set" "sk_as" {
  name                = "sk_as"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
}

resource "azurerm_network_interface" "sk_nic" {
  count               = 2
  name                = "sk_nic_${count.index}"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name

  ip_configuration {
    name                          = "sk_nic_ipconfig"
    subnet_id                     = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${azurerm_resource_group.sk_rg.name}/providers/Microsoft.Network/virtualNetworks/sk_vnet/subnets/sk_subnet"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sk_pip.id
  }
}

resource "azurerm_virtual_machine" "sk_vm" {
  count               = 2
  name                = "sk_vm_${count.index}"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  availability_set_id = azurerm_availability_set.sk_as.id
  vm_size             = "Standard_DS1_v2"   # or any other valid Azure VM size

  network_interface_ids = [
    azurerm_network_interface.sk_nic.*.id[count.index],
  ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sk_osdisk_${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sk_vm_${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.sk_sa.primary_blob_endpoint}"
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_storage_account" "sk_sa" {
  name                     = "skstrg${random_integer.random_integer.result}"
  resource_group_name      = azurerm_resource_group.sk_rg.name
  location                 = azurerm_resource_group.sk_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sk_container" {
  name                  = "sk-container"
##  resource_group_name   = azurerm_resource_group.sk_rg.name
  storage_account_name  = azurerm_storage_account.sk_sa.name
  container_access_type = "private"
}

resource "azurerm_mariadb_server" "sk_db" {
  name                = "sk-db"
  location            = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
  administrator_login          = "sk_admin"
  administrator_login_password = "Password1234!"
  sku_name            = "B_Gen5_1"
  version             = "10.3"
  ssl_enforcement_enabled = true

##  storage_profile {
##    storage_mb            = 5120
##    backup_retention_days = 7
##    geo_redundant_backup  = "Disabled"
##  }
}

resource "azurerm_mariadb_database" "sk_db_wp" {
  name                = "sk_db_wp"
  resource_group_name = azurerm_resource_group.sk_rg.name
  server_name         = azurerm_mariadb_server.sk_db.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_lb_backend_address_pool" "sk_lb_pool" {
  name = "sk_lb_pool"
##  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id = azurerm_lb.sk_lb.id
}

resource "azurerm_lb_rule" "sk_lb_rule" {
  name                = "sk-lb-rule"
##  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id     = azurerm_lb.sk_lb.id
  protocol            = "Tcp"
  frontend_port       = 80
  backend_port        = 80
  enable_floating_ip  = false
  idle_timeout_in_minutes = 5
  frontend_ip_configuration_name = azurerm_lb_frontend_ip_configuration.sk_lb_fe.name
}

resource "azurerm_lb_probe" "sk_lb_probe" {
  name = "sk_lb_probe"
##  resource_group_name = azurerm_resource_group.sk_rg.name
  loadbalancer_id = azurerm_lb.sk_lb.id
  protocol = "Tcp"
  port = 80
##  interval = 15
  number_of_probes = 2
}

resource "azurerm_monitor_diagnostic_setting" "sk_monitor" {
  name               = "sk-monitor"
  target_resource_id = azurerm_virtual_machine.sk_vm.*.id[count.index]

  log_analytics_workspace_id = azurerm_log_analytics_workspace.sk_law.id

  metric {
    category = "AllMetrics"

    enabled = true
    time_grain = "PT1M"
  }

  log {
    category = "LinuxSyslog"
    enabled_log = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

resource "random_integer" "random_integer" {
  min = 1000
  max = 9999
}

resource "azurerm_virtual_network" "sk_vnet" {
  name = "sk_vnet"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.sk_rg.location
  resource_group_name = azurerm_resource_group.sk_rg.name
}

resource "azurerm_subnet" "sk_subnet" {
  name = "sk_subnet"
  resource_group_name = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes = ["10.0.1.0/24"]
}

##output "public_ip_address" {
##  value = azurerm_public_ip.sk_pip.ip_address
##}

##output "load_balancer_dns_name" {
##  value = azurerm_lb.sk_lb.frontend_ip_configuration.0.fqdn
##}