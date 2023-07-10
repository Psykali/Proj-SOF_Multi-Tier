###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
resource "azurerm_mysql_server" "mysql" {
  name                = "wordpress-mysql"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "B_Gen5_2"

  storage_mb = 5120
  version    = "5.7"

  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

resource "azurerm_mysql_database" "wordpress" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = var.app_service
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    always_on       = true
    linux_fx_version= "DOCKER|wordpress:latest"
    app_command_line= ""
    
    app_settings {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE= false
      WORDPRESS_DB_HOST                  = "${azurerm_mysql_server.mysql.fqdn}:3306"
      WORDPRESS_DB_USER                  = azurerm_mysql_server.mysql.administrator_login
      WORDPRESS_DB_PASSWORD              = azurerm_mysql_server.mysql.administrator_login_password
      WORDPRESS_DB_NAME                  = azurerm_mysql_database.wordpress.name
    }
    
    connection_string {
      name  = "dbconnectionstring"
      type  = "MySQL"
      value = "${azurerm_mysql_server.mysql.administrator_login}@${azurerm_mysql_server.mysql.fqdn}:3306/${azurerm_mysql_database.wordpress.name}"
    }
      site_config {
    cors {
      allowed_origins     = []
      support_credentials = false
    }

    ftps_state = "AllAllowed"

    http2_enabled = true

    ip_restriction {
      action                 = "Allow"
      ip_address             = "<IPAddress>/32"
      name                   = "<IPAddress>"
      priority               = 100
      service_tag            = ""
      virtual_network_subnet_id = ""
    }

    min_tls_version = "1.2"

    number_of_workers = 1

    remote_debugging_enabled = false

    remote_debugging_version = ""

    scm_ip_restriction {
      action                 = ""
      ip_address             = ""
      name                   = ""
      priority               = null
      service_tag            = ""
      virtual_network_subnet_id = ""
    }

    scm_type = ""

    use_32_bit_worker_process = false

    websockets_enabled = false

    windows_fx_version = ""

    default_documents = []

    http20_enabled = true

    local_mysql_enabled = false

    managed_pipeline_mode = ""

    php_version = ""

    python_version = ""

    reserved_instance_count = null

    virtual_application {
      physical_path   = ""
      virtual_path    = ""
      preload_enabled = false

      virtual_directory {
        physical_path   = ""
        virtual_path    = ""
        preload_enabled = false
        virtual_application_name=""
        virtual_directory_name=""
      }
    }
  }
}