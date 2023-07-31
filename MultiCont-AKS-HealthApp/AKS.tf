######################
## Create Azure AKS ##
######################
resource "azurerm_kubernetes_cluster" "psykprojs" {
  name                = var.kubernetes_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name            = var.node_pool_name
    node_count      = 3
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

#  depends_on = [
#    azurerm_subnet.aks,
#  ]
}
#######################
## Define Name space ##
#######################
#resource "azurerm_kubernetes_namespace" "psykprojs" {
#  name                = var.namespace_name
#  depends_on          = [azurerm_kubernetes_cluster.psykprojs]
#  kubernetes_cluster_id = azurerm_kubernetes_cluster.psykprojs.id
#}
#############
## Outputs ##
#############
output "acrLoginServer" {
  value = azurerm_container_registry.psykprojs.login_server
}

output "controlPlaneFQDN" {
  value = azurerm_kubernetes_cluster.psykprojs.fqdn
}