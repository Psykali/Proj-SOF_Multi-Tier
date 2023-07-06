provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "acr" {
  name                = "skcontreg"
  resource_group_name = "PERSO_SIEF"
  location            = "francecentral"

  sku {
    name = "Premium"

    replication {
      location                = "westeurope"
      zone_redundancy_enabled = true
    }

    replication {
      location                = "northeurope"
      zone_redundancy_enabled = true
    }
  }

  admin_enabled = false

  tags = {
    environment = "production"
  }
} 