resource "azurerm_log_analytics_workspace" "skprjs_la" {
  name                = "skprjs-log-analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

resource "azurerm_container_group" "skprjs_container" {
  name                = "Sofstaging-container"
  location            = var.location
  resource_group_name = var.resource_group_name

  os_type = "Linux"

  container {
    name   = "skprjs-webapp"
    image  = "skP20ContReg.azurecr.io/dev/stackoverp20kcab"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      protocol = "TCP"
      port     = 80
    }
  }

  tags = local.common_tags

  diagnostics {
    log_analytics {
#      workspace_id  = azurerm_log_analytics_workspace.skprjs_la.id
      workspace_key = azurerm_log_analytics_workspace.skprjs_la.primary_shared_key
    }
  }
}