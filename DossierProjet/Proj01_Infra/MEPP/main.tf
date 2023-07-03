provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "skstorageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "sk-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "sk-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_lb" "lb" {
  name                = "sk-lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "sk-lb-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "sk-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "wordpress1" {
  name                = "sk-wordpress1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on = true
  }
}

resource "azurerm_app_service" "wordpress2" {
  name                = "sk-wordpress2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  site_config {
    always_on = true
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "sk-app-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "sk-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_bastion_host" "bastion" {
  name                = "sk-bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
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
  collation           = "SQL_Latin1_General_CP1_CI_AS"
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  loadbalancer_id         = azurerm_lb.lb.id
  backend_address_pool_id = azurerm_app_service.wordpress1.app_service_plan_id
}

resource "azurerm_lb_probe" "probe" {
  name                = "sk-lb-probe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  interval            = 5
  unhealthy_threshold = 2
  pick_host_name_from_http_settings = true
  request_path        = "/"
  match {
    status_codes = ["200-399"]
  }
}

resource "azurerm_blob_storage_container" "blob_container" {
  name                  = "sk-blob-container"
  resource_group_name   = azurerm_resource_group.rg.name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

resource "azurerm_monitor_diagnostic_setting" "app_insights_diagnostic" {
  name                           = "sk-app-insights-diagnostic"
  target_resource_id             = azurerm_application_insights.app_insights.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.log_analytics_workspace.id
  application_logs {
    retention_policy {
      enabled = true
      days    = 90
    }
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "sk-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "action_group" {
  name                = "sk-action-group"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "sk-ag"
  email_receiver {
    name          = "email"
    email_address = "your-email@example.com"
  }
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  name                = "sk-metric-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_app_service.wordpress1.id, azurerm_app_service.wordpress2.id]
  description         = "Alert triggered when memory usage exceeds threshold"
  severity            = 3
  enabled             = true

  criteria {
    metric_namespace = "microsoft.web/sites"
    metric_name      = "memoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    dimensions {
      name     = "name"
      operator = "Include"
      values   = [azurerm_app_service.wordpress1.name, azurerm_app_service.wordpress2.name]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group.id
  }
}