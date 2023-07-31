### Create Azure AKS
resource "azurerm_kubernetes_cluster" "psykprojs" {
  name                = "psykprojs-aks"
  location            = var.resource_group_name
  resource_group_name = var.location
  dns_prefix          = "psykprojs-aks"
  kubernetes_version  = "1.14.7"

  default_node_pool {
    name                = "psykprojs-agentpool"
    node_count          = 3
    vm_size             = "Standard_D2_v2"
    os_type             = "Linux"
    os_disk_size_gb     = 0
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = "ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm"
    }
  }

  service_principal {
    client_id     = "n/a"
    client_secret = "n/a"
  }
}

output "acrLoginServer" {
  value = azurerm_container_registry.psykprojs.login_server
}

output "controlPlaneFQDN" {
  value = azurerm_kubernetes_cluster.psykprojs.fqdn
}
