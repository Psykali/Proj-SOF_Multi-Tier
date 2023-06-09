resource "azurerm_kubernetes_cluster" "example" {
  name                = "SK-MEPP-AKS"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  dns_prefix          = "skmeppdns"

  default_node_pool {
    name       = "skmepppl"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "DEV"
  }
}