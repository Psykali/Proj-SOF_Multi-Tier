############################################
#resource "azurerm_resource_group" "rg" {
#  name     = "persosief"
#  location = "France Central"
#}
############################################
resource "azurerm_sql_server" "sqlserver" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

resource "azurerm_sql_database" "sqldb" {
  name                = var.sql_database_name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.sqlserver.name
}

resource "docker_image" "my_image" {
  name = "sksof:latest"
  build {
    context = "./dockerfile"
  features: {
    "buildkit": false
  }
  }
  depends_on = [azurerm_sql_database.sqldb]
}

resource "docker_container" "my_container" {
  image = docker_image.my_image.name
  name  = "sksofcont"
  env = [
    "DB_SERVER=${azurerm_sql_server.sqlserver.fully_qualified_domain_name}",
    "DB_NAME=${azurerm_sql_database.sqldb.name}",
    "DB_USER=${azurerm_sql_server.sqlserver.administrator_login}",
    "DB_PASSWORD=${azurerm_sql_server.sqlserver.administrator_login_password}"
  ]
}

resource "azurerm_container_group" "cg" {
  name                = "skcontgrp"
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_address_type     = "Public"
  dns_name_label      = "sksof"
  os_type             = "Linux"

  container {
    name   = docker_container.my_container.name
    image  = docker_image.my_image.name
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
