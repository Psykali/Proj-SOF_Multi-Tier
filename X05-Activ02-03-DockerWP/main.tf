###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
### Create the SQL Server
##resource "azurerm_sql_server" "sql_server" {
##  name                         = var.sql_server_name
##  location                     = var.location
##  resource_group_name          = var.resource_group_name
##  version                      = "12.0"
##  administrator_login          = var.admin_username
##  administrator_login_password = var.admin_password
##}
##############################################################
### Create firewall rule for SQL Server
##resource "azurerm_sql_firewall_rule" "sql_firewall_rule" {
##  name                = "AllowAll"
##  resource_group_name = var.resource_group_name
##  server_name         = azurerm_sql_server.sql_server.name
##  start_ip_address    = "0.0.0.0"
##  end_ip_address      = "255.255.255.255"
##}
##############################################################
### Create SQL Database
##resource "azurerm_sql_database" "sql_database" {
##  name                = var.sql_database_name
##  location            = var.location
##  resource_group_name = var.resource_group_name
##  server_name         = azurerm_sql_server.sql_server.name
##  edition             = "GeneralPurpose"
##  requested_service_objective_name = "GP_Gen5_2"
##}
###############################################################
resource "azurerm_mariadb_server" "mariadb_server" {
  name                = var.sql_database_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  ssl_enforcement_enabled = true
}

resource "azurerm_mariadb_database" "mariadb_database" {
  name                = "wordpress"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mariadb_server.mariadb_server.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "skdwpsa"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storage_container" {
  name                  = "skdwpblob"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Create the Azure Container Instance
resource "azurerm_container_group" "aci" {
  name                = var.container_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = "${var.container_name}-dns"
  os_type             = "Linux"

  image_registry_credential {
    server   = "skp20contreg.azurecr.io"
    username = var.scope_map_token_name
    password = var.scope_map_token_password
  }

  container {
    name   = "${var.container_name}-1"
    image  = var.image_name
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  container {
    name   = "${var.container_name}-2"
    image  = var.image_name
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
    
  environment_variables = {
      WORDPRESS_DB_HOST     = azurerm_mariadb_server.mariadb_server.fqdn
      WORDPRESS_DB_USER     = azurerm_mariadb_server.mariadb_server.administrator_login
      WORDPRESS_DB_PASSWORD = azurerm_mariadb_server.mariadb_server.administrator_login_password
      WORDPRESS_DB_NAME     = azurerm_mariadb_database.mariadb_database.name
    }
    
##    environment_variables = {
##      WORDPRESS_DB_HOST     = var.sql_server_fqdn
##      WORDPRESS_DB_USER     = var.admin_username
##      WORDPRESS_DB_PASSWORD = var.admin_password
##      WORDPRESS_DB_NAME     = var.sql_database_name
##      WORDPRESS_DB_SSL = "true"
##    }
  }
}
resource "azurerm_monitor_action_group" "main" {
  name                = "sk-actiongroup"
  resource_group_name = var.resource_group_name
  short_name          = "skact"

  email_receiver {
    name                    = "sendtoadmin"
    email_address           = "skhalifa@simplonformations.onmicrosoft.com"
    use_common_alert_schema = true
  }
}


resource "azurerm_monitor_metric_alert" "example" {
  name                = "example-metricalert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_group.aci.id]
  description         = "Action will be triggered when CPU usage is greater than 80%."

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    # specify the ID of the action group you want to use
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
