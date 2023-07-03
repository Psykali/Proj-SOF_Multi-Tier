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
}

resource "azurerm_subnet" "subnet" {
  name                 = "sk-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "sk-nsg"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
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
    always_on           = true
    linux_fx_version    = "DOCKER|wordpress"
    connection_strings = [
      {
        name  = "DB_CONNECTION_STRING"
        value = azurerm_sql_database.sql_db.connection_strings[0].value
        type  = "SQLAzure"
      }
    ]
  }
}

resource "azurerm_sql_server" "sql_server" {
  name                = "sk-sql-server"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"
  administrator_login = "admin"
  administrator_login_password = "P@ssw0rd"
}

resource "azurerm_sql_database" "sql_db" {
  name                = "sk-sql-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql_server.name
  edition             = "GeneralPurpose"
  compute_model       = "Serverless"
  min_capacity        = 0.5
  max_capacity        = 2
  auto_pause_delay     = 60
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "sk-action-group"
  resource_group_name = azurerm_resource_group.rg.name

  email_receiver {
    name          = "email1"
    email_address = "your-email@example.com"
  }
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  name                = "sk-metric-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_app_service.wordpress.id]
  description         = "High CPU utilization alert"
  severity            = 3

  criteria {
    metric_namespace = "microsoft.web/sites"
    metric_name      = "cpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimensions {
      name     = "name"
      operator = "Include"
      values   = [azurerm_app_service.wordpress.name]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}

output "wordpress_url" {
  value = azurerm_app_service.wordpress.default_site_hostname
}