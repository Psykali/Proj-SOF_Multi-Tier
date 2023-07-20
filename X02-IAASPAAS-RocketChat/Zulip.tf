# Zulip Web App
resource "azurerm_app_service" "zulip_app" {
  name                = var.zulip_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    linux_fx_version = "DOCKER|zulip/docker-zulip:4.8-0"
    scm_type         = "None"
  }

  app_settings = {
    "SECRETS_email_password"      = var.zulip_email_password
    "SECRETS_rabbitmq_password"   = var.zulip_rabbitmq_password
    "SECRETS_postgres_password"   = var.zulip_postgres_password
    "SECRETS_memcached_password"  = var.zulip_memcached_password
    "SECRETS_redis_password"      = var.zulip_redis_password
    "SETTING_EXTERNAL_HOST"       = var.zulip_external_host
    "SETTING_ZULIP_ADMINISTRATOR" = var.zulip_administrator_email
    "SETTING_ADMIN_DOMAIN"        = var.zulip_admin_domain
  }
}