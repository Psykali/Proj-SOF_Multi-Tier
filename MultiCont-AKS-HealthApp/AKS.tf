### Create Azure AKS
resource "azurerm_kubernetes_cluster" "psykprojs" {
  name                = var.kubernetes_cluster_name
  location            = var.resource_group_name
  resource_group_name = var.location
  dns_prefix          = var.dns_prefix
  kubernetes_version  = "1.14.7"

  default_node_pool {
    name                = var.node_pool_name
    node_count          = 3
    vm_size             = "Standard_D2_v2"
    os_type             = "Linux"
    os_disk_size_gb     = 0
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = "ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm"
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_namespace" "psykprojs" {
  name                = var.namespace_name
  depends_on          = [azurerm_kubernetes_cluster.psykprojs]
  kubernetes_cluster_id = azurerm_kubernetes_cluster.psykprojs.id
}

output "acrLoginServer" {
  value = azurerm_container_registry.psykprojs.login_server
}

output "controlPlaneFQDN" {
  value = azurerm_kubernetes_cluster.psykprojs.fqdn
}
