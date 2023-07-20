# Server Wiki Web App
resource "azurerm_app_service" "server_wiki_app" {
  name                = var.server_wiki_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|requarks/wiki:2"
    scm_type         = "None"
  }

  app_settings = {
    "WIKI_ADMIN_EMAIL"    = var.wiki_admin_email
    "WIKI_ADMIN_PASSWORD" = var.wiki_admin_password
    "DB_TYPE"             = "mysql"
    "DB_HOST"             = azurerm_mysql_server.mysql.fqdn
    "DB_PORT"             = 3306
    "DB_USER"             = azurerm_mysql_server.mysql.administrator_login
    "DB_PASS"             = azurerm_mysql_server.mysql.administrator_login_password
    "DB_NAME"             = azurerm_mysql_database.mysql_db.name
  }
    ##    app_settings = {
    ##        "WIKI_ADMIN_EMAIL"    = var.wiki_admin_email
    ##        "WIKI_ADMIN_PASSWORD" = var.wiki_admin_password
    ##        "DB_TYPE"             = "postgres"
    ##        "DB_HOST"             = azurerm_postgresql_server.postgres.fqdn
    ##        "DB_PORT"             = 5432
    ##        "DB_USER"             = azurerm_postgresql_server.postgres.administrator_login
    ##        "DB_PASS"             = azurerm_postgresql_server.postgres.administrator_login_password
    ##        "DB_NAME"             = azurerm_postgresql_database.postgres_db.name
    ##    }
}
##https://hub.docker.com/r/linuxserver/wikijs
##https://hub.docker.com/_/mediawiki