resource "azurerm_kubernetes_cluster" "example" {
  name                = "PersoSief-AKS"
  location            = "France Central"
  resource_group_name = "PERSO_SIEF"
  dns_prefix          = "persosiefdns"

  default_node_pool {
    name       = "persosiefpl"
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

#output "client_certificate" {
#  value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
#  sensitive = true
#}

#output "kube_config" {
#  value = azurerm_kubernetes_cluster.example.kube_config_raw
#
#  sensitive = true
#}

resource "null_resource" "deploy-yaml" {

  provisioner "local-exec" {
      command = "kubectl apply -f config.yml"
  }
}
