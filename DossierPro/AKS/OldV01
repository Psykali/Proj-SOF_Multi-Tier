resource "azurerm_kubernetes_cluster" "example" {
  name                = "SK-AKS"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  dns_prefix          = "skmepdns"

  default_node_pool {
    name       = "skmeppl"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}