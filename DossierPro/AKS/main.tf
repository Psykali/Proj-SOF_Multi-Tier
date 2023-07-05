# Define the provider
provider "azurerm" {
  features {}
}

# Define the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-cluster"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  dns_prefix          = "aks-cluster"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  depends_on = [
    azurerm_subnet.aks,
  ]
}

# Define the subnet
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = "PERSO_SIEF"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define the virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
}

# Define the public IP address
resource "azurerm_public_ip" "aks" {
  name                = "aks-public-ip"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"
  allocation_method   = "Static"
}

# Define the load balancer
resource "azurerm_lb" "aks" {
  name                = "aks-lb"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  frontend_ip_configuration {
    name                          = "aks-lb-public-ip"
    public_ip_address_id          = azurerm_public_ip.aks.id
  }
}

# Define the load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "aks" {
  name                = "aks-lb-backend-pool"
  loadbalancer_id     = azurerm_lb.aks.id
}

# Define the load balancer rule
resource "azurerm_lb_rule" "aks" {
  name                   = "aks-lb-rule"
  frontend_ip_configuration_name = azurerm_lb.aks.frontend_ip_configuration[0].name
  loadbalancer_id        = azurerm_lb.aks.id
  protocol               = "Tcp"
  frontend_port          = 80
  backend_port           = 80
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.aks.id]
}

# Define the network interface
resource "azurerm_network_interface" "aks" {
  name                = "aks-nic"
  location            = "francecentral"
  resource_group_name = "PERSO_SIEF"

  ip_configuration {
    name                          = "aks-nic-ipconfig"
    subnet_id                     = azurerm_subnet.aks.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the Kubernetes namespace for sof-p20
resource "kubernetes_namespace" "sof_p20" {
  metadata {
    name = "sof-p20"
  }
}

# Define the Kubernetes deployment for sof-p20
resource "kubernetes_deployment" "sof_p20" {
  metadata {
    name      = "sof-p20"
    namespace = kubernetes_namespace.sof_p20.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "sof-p20"
      }
    }

    template {
      metadata {
        labels = {
          app = "sof-p20"
        }
      }

      spec {
        container {
          image = "psykali/stackoverp20kcab:latest"
          name  = "sof-p20"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Define the Kubernetes service for sof-p20
resource "kubernetes_service" "sof_p20" {
  metadata {
    name      = "sof-p20"
    namespace = kubernetes_namespace.sof_p20.metadata[0].name
  }

  spec {
    selector = {
      app = "sof-p20"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

# Define the Kubernetes namespace for wp
resource "kubernetes_namespace" "wp" {
  metadata {
    name = "wp"
  }
}

# Define the Kubernetes deployment for wp
resource "kubernetes_deployment" "wp" {
  metadata {
    name      = "wp"
    namespace = kubernetes_namespace.wp.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wp"
      }
    }

    template {
      metadata {
        labels = {
          app = "wp"
        }
      }

      spec {
        container {
          image = "wordpress/wordpress:latest"
          name  = "wp"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Define the Kubernetes service for wp
resource "kubernetes_service" "wp" {
  metadata {
    name      = "wp"
    namespace = kubernetes_namespace.wp.metadata[0].name
  }

  spec {
    selector = {
      app = "wp"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}