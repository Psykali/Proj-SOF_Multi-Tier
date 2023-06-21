# Configure the Azure provider
#provider "azurerm" {
#  features {}
#}
#
# Create a resource group
resource "azurerm_resource_group" "sk_rg" {
  name     = "sk_rg"
  location = "francecentral"
}

# Create a virtual machine running MariaDB
resource "azurerm_linux_virtual_machine" "sk_mariadb_vm" {
  name                = "sk_mariadb_vm"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  size                = "Standard_D2_v2"
  admin_username      = "adminuser"
  admin_password      = "Password1234!"
  network_interface_ids = [
    azurerm_network_interface.sk_mariadb_vm.id,
  ]
}

# Create a network interface for the virtual machine
resource "azurerm_network_interface" "sk_mariadb_vm" {
  name                = "sk_mariadb_vm_nic"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location

  ip_configuration {
    name                          = "sk_mariadb_vm_ipconfig"
    subnet_id                     = azurerm_subnet.sk_mariadb_vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a subnet for the virtual machine
resource "azurerm_subnet" "sk_mariadb_vm" {
  name                 = "sk_mariadb_vm_subnet"
  resource_group_name  = azurerm_resource_group.sk_rg.name
  virtual_network_name = azurerm_virtual_network.sk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a virtual network for the virtual machine
resource "azurerm_virtual_network" "sk_vnet" {
  name                = "sk_vnet"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  address_space       = ["10.0.0.0/16"]

  subnet {
    name                 = "sk_subnet"
    address_prefix       = "10.0.1.0/24"
  }
}

# Create a load balancer for the web applications
resource "azurerm_lb" "sk_web_lb" {
  name                = "sk_web_lb"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location

  frontend_ip_configuration {
    name                          = "sk_web_lb_frontend_ipconfig"
    subnet_id                     = azurerm_subnet.sk_web_lb.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name = "sk_web_lb_backend_pool"
  }

  probe {
    name                = "sk_web_lb_probe"
    protocol            = "Http"
    request_path        = "/"
    port                = 80
    interval_in_seconds = 15
    number_of_probes    = 2
  }

  load_balancing_rule {
    name                       = "sk_web_lb_rule"
    frontend_ip_configuration = azurerm_lb.sk_web_lb.frontend_ip_configuration[0].id
    backend_address_pool       = azurerm_lb.sk_web_lb.backend_address_pool[0].id
    probe_id                   = azurerm_lb.sk_web_lb.probe[0].id
    protocol                   = "Tcp"
    frontend_port              = 80
    backend_port               = 80
  }
}

# Create the web applications
resource "azurerm_app_service_plan" "sk_web_app_service_plan" {
  name                = "sk_web_app_service_plan"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  sku_tier            = "Standard"
  sku_size            = "S1"
}

resource "azurerm_app_service" "sk_web_app" {
  count               = 2
  name                = "sk_web_app_${count.index}"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
  app_service_plan_id = azurerm_app_service_plan.sk_web_app_service_plan.id

  site_config {
    dotnet_framework_version = "v5.0"
  }

  connection_string {
    name  = "sk_mariadb_vm_connection_string"
    type  = "MySQL"
    value = "PAAS connection string"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.sk_app_insights.instrumentation_key
  }

  depends_on = [
    azurerm_lb.sk_web_lb,
  ]
}

# Create an Application Insights resource
resource "azurerm_application_insights" "sk_app_insights" {
  name                = "sk_app_insights"
  resource_group_name = azurerm_resource_group.sk_rg.name
  location            = azurerm_resource_group.sk_rg.location
}

# Create a storage account for the application blobs
resource "azurerm_storage_account" "sk_storage_account" {
  name                     = "sk_storage_account"
  resource_group_name      = azurerm_resource_group.sk_rg.name
  location                 = azurerm_resource_group.sk_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

# Enable blob storage encryption for the storage account
resource "azurerm_storage_account_encryption_scope" "sk_encryption_scope" {
  name                = "sk_encryption_scope"
  resource_group_name = azurerm_resource_group.sk_rg.name
  storage_account_name = azurerm_storage_account.sk_storage_account.name

  source {
    type = "Microsoft.Storage/storageAccounts"
    id   = azurerm_storage_account.sk_storage_account.id
  }

  encryption_scope {
    enabled = true
    default_encryption_action {
      type = "EncryptIfNotEncrypted"
    }
    blob_services {
      default_service_version = "2022-02-14"
      container_level_encryption {
        enabled = true
        default_encryption_action {
          type = "EncryptIfNotEncrypted"
        }
      }
    }
  }
}

# Create a container in the storage account for the application blobs
resource "azurerm_storage_container" "sk_storage_container" {
  name                  = "sk_storage_container"
  storage_account_name  = azurerm_storage_account.sk_storage_account.name
  container_access_type = "private"
}