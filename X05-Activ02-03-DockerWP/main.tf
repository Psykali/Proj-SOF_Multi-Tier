variable "rg-name" {
  default = "PERSO_SIEF"
}

variable "location" {
  default = "francecentral"
}

variable "adminUser" {
  default = "myadmin"
}

variable "password" {
  default = "myP@ssW0rd!!"
}

variable "serverName" {
  default = "mysqlserver-${random_integer.r.result}"
}

resource "random_integer" "r" {
  min = 10000
  max = 99999
}

##resource "azurerm_resource_group" "rg" {
##  name     = var.rg-name
##  location = var.location
##}

resource "azurerm_sql_server" "sql" {
  name                         = var.serverName
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.adminUser
  administrator_login_password = var.password
}

resource "azurerm_sql_database" "db" {
  name                = "wordpressdb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
}

resource "azurerm_sql_firewall_rule" "fw" {
  name                = "allAzureIPs"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_container_group" "wordpress" {
  name                = "wordpress"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "public"
  dns_name_label      = "mywordpress"
  os_type             = "Linux"

  container {
    name   = "wordpress"
    image  = "wordpress:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      WORDPRESS_DB_HOST     = "${azurerm_sql_server.sql.fully_qualified_domain_name},${azurerm_sql_database.db.name}"
      WORDPRESS_DB_USER     = "${var.adminUser}@${azurerm_sql_server.sql.name}"
      WORDPRESS_DB_PASSWORD = var.password
      WORDPRESS_DB_NAME     = azurerm_sql_database.db.name
    }
    
    secure_environment_variables = {
      WORDPRESS_DB_SSL_CA   ="https://www.digicert.com/CACerts/BaltimoreCyberTrustRoot.crt.pem"
    }
    
    commands=["docker-entrypoint.sh", "--wait-for-mysql"]
    
    liveness_probe{
        http_get{
            path="/wp-admin/install.php"
            port=80
        }
        initial_delay_seconds=120
        period_seconds=60
        failure_threshold=3
        
    }
    
    readiness_probe{
        http_get{
            path="/wp-admin/install.php"
            port=80
        }
        initial_delay_seconds=120
        period_seconds=60
        failure_threshold=3
        
    }
}
}