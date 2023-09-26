resource "azurerm_container_group" "skprjs_aci" {
  name                = "SofStaging-aci"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "public"
  dns_name_label      = "SofStaging-aci"
  os_type             = "Linux"

  container {
    name   = "SofStaging-aci"
    image  = "skP20ContReg.azurecr.io/dev/stackoverp20kcab"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      "WEBSITES_PORT"                   = "80"
      "APPINSIGHTS_INSTRUMENTATIONKEY"  = azurerm_application_insights.skprjs_ai.instrumentation_key
      "DATABASE_NAME"                   = var.db_name
      "MYSQL_HOST"                      = var.db_host
      "MYSQL_PORT"                      = "1433"
      "MYSQL_USER"                      = var.admin_username
      "MYSQL_PASSWORD"                  = var.admin_password
    }
  }

  tags = local.common_tags
}
