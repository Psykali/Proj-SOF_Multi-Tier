resource "azurerm_resource_group" "rg" {
  name     = "wordpress-rg"
  location = "West US"
}

resource "azurerm_mysql_server" "mysql" {
  name                = "wordpress-mysql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_2"

  storage_mb = 5120
  version    = "5.7"

  administrator_login          = "mysqladmin"
  administrator_login_password = "H@Sh1CoR3!"
}

resource "azurerm_mysql_database" "wordpress" {
  name                = "wordpress"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_container_registry" "acr" {
    name                = "wordpressacr"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Basic"
    admin_enabled       = true
}

resource "azurerm_container_group" "cg" {
    name                = "wordpress-cg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_address_type     = "public"
    dns_name_label      = "wordpress-dns"
    os_type             = "Linux"

    container {
        name   = "wordpress"
        image  = "${azurerm_container_registry.acr.login_server}/wordpress:latest"
        cpu    = "0.5"
        memory = "1.5"

        ports {
            port     = 80
            protocol = "TCP"
        }

        environment_variables = {
            WORDPRESS_DB_HOST     = "${azurerm_mysql_server.mysql.fqdn}:3306"
            WORDPRESS_DB_USER     = azurerm_mysql_server.mysql.administrator_login
            WORDPRESS_DB_PASSWORD = azurerm_mysql_server.mysql.administrator_login_password
            WORDPRESS_DB_NAME     = azurerm_mysql_database.wordpress.name
        }
        
        secure_environment_variables= {
            WORDPRESS_DB_PASSWORD= azurerm_mysql_server.mysql.administrator_login_password
        }
    }

    image_registry_credential {
        server   = azurerm_container_registry.acr.login_server
        username = azurerm_container_registry.acr.admin_username
        password= azurerm_container_registry.acr.admin_password
    }
}
