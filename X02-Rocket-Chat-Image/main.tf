terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Deploy MongoDB instance
resource "azurerm_cosmosdb_account" "mongodb" {
  name                = "my-mongodb-instance"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  offer_type          = "Standard"
  kind                = "MongoDB"
  consistency_policy {
    consistency_level = "Session"
  }
  is_virtual_network_filter_enabled = false
  enable_automatic_failover         = false
  enable_multiple_write_locations   = false

  geo_location {
    location          = "eastus"
    failover_priority = 0
  }

  capabilities {
    name = "EnableAggregationPipeline"
  }

  #failover_policy {
  #  mode = "Manual"
  #}

  tags = {
    environment = "dev"
  }
}

# Deploy Rocket.Chat container
resource "azurerm_container_group" "rocket_chat_aci" {
  name                = "my-rocket-chat"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"

  os_type = "Linux"

  depends_on = [azurerm_cosmosdb_account.mongodb]

  container {
    name   = "rocket-chat"
    image  = "rocketchat/rocket.chat"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = "3000"
      protocol = "TCP"
    }

    environment_variables = {
      MONGO_URL                  = azurerm_cosmosdb_account.mongodb.connection_strings[0]
      ROOT_URL                   = "http://<my-domain>"
      PORT                       = "3000"
      Accounts_UseDNSDomainCheck = "false"
    }

    ip_address {
      type = "public"
    }
  }
}

output "fqdn" {
  value = azurerm_container_group.rocket_chat_aci.fqdn
}

output "port" {
  value = azurerm_container_group.rocket_chat_aci.container_ports[0].port
}