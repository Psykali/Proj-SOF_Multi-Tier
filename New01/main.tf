###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################################
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

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

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

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "wordpress"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster
  ]
}

resource "kubernetes_secret" "db_secret" {
  metadata {
    name      = "db-secret"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    db_host     = azurerm_mariadb_server.mariadb_server.fqdn
    db_user     = azurerm_mariadb_server.mariadb_server.administrator_login
    db_password = azurerm_mariadb_server.mariadb_server.administrator_login_password
    db_name     = azurerm_mariadb_database.mariadb_database.name
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster,
    kubernetes_namespace.namespace,
    azurerm_mariadb_server.mariadb_server,
    azurerm_mariadb_database.mariadb_database,
  ]
}

resource "kubernetes_deployment" "wordpress_deployment" {
  metadata {
    name      = "wordpress-deployment"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels    = { app : "wordpress" }
  }

  spec {
    replicas = 3

    selector {
      match_labels = { app : "wordpress" }
    }

    template {
      metadata {
        labels      = { app : "wordpress" }
      }

      spec {
        container {
          name              = "${var.cluster_name}-container-1"
          image             = "<image>"
          image_pull_policy = "Always"

          port {
            container_port   = <port>
            protocol         = <protocol>
          }

          env_from {
            secret_ref {
              name      = kubernetes_secret.db_secret.metadata[0].name
            }
          }
        }
      }
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
  name                = "sk-metricalert"
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
