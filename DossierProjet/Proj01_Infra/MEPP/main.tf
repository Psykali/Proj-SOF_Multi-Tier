provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}


resource "azurerm_virtual_network" "vnet" {
  name                = "sk-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "subnet" {
  name                 = "sk-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "sk-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_availability_set" "availability_set" {
  name                = "sk-availability-set"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  platform_fault_domain_count = 3
  platform_update_domain_count = 5
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "sk-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  availability_set_id   = azurerm_availability_set.availability_set.id
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_D2_v3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sk-vm"
    admin_username = "adminuser"
    admin_password = "password"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "sk-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "config1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "sk-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "wordpress" {
  name                = "sk-wordpress"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  site_config {
    always_on            = true
    linux_fx_version     = "DOCKER|wordpress"
    app_command_line     = ""
    scm_type             = "LocalGit"
    use_32_bit_worker_process = true
  }
  connection_string {
    name  = "db_connection"
    type  = "SQLAzure"
    value = azurerm_sql_database.sql_db.connection_strings[0].value
  }
  depends_on = [azurerm_sql_database.sql_db]
}

resource "azurerm_storage_container" "container" {
  name                  = "sk-container"
  resource_group_name   = azurerm_resource_group.rg.name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "sk-action-group"
  resource_group_name = azurerm_resource_group.rg.name

  email_receiver {
    name          = "email"
    email_address = "admin@example.com"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "sk-app-insights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "sk-log-analytics"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
}

resource "azurerm_sql_server" "sql_server" {
  name                         = "sk-sql-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "password"
}

resource "azurerm_sql_database" "sql_db" {
  name                = "sk-sql-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql_server.name
  sku_name            = "BC_Gen5_2"
  collation_name      = "SQL_Latin1_General_CP1_CI_AS"
  edition             = "Standard"

  connection_policy {
    connection_mode = "Default"
    ip_address {
      subnet_id = azurerm_subnet.subnet.id
    }
  }
}

output "wordpress_url" {
  value = azurerm_app_service.wordpress.default_site_hostname
}