# Define the provider
provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "rg" {
  name     = "PERSO_SIEF"
  location = "francecentral"
}

# Define the AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "SK-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "YOUR_AZURE_CLIENT_ID"
    client_secret = "YOUR_AZURE_CLIENT_SECRET"
  }

  tags = {
    Environment = "Production"
  }
}

# Define the Kubernetes namespace
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "my-app-namespace"
  }
}

# Define the Kubernetes deployment for App 1
resource "kubernetes_deployment" "app1_deployment" {
  metadata {
    name      = "app1-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "app1"
      }
    }

    template {
      metadata {
        labels = {
          app = "app1"
        }
      }

      spec {
        container {
          name  = "app1-container"
          image = "your-registry/app1:latest"
        }
      }
    }
  }
}

# Define the Kubernetes service for App 1
resource "kubernetes_service" "app1_service" {
  metadata {
    name      = "app1-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "app1"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

# Define the Kubernetes deployment for App 2
resource "kubernetes_deployment" "app2_deployment" {
  metadata {
    name      = "app2-deployment"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app2"
      }
    }

    template {
      metadata {
        labels = {
          app = "app2"
        }
      }

      spec {
        container {
          name  = "app2-container"
          image = "your-registry/app2:latest"
        }
      }
    }
  }
}

# Define the Kubernetes service for App 2
resource "kubernetes_service" "app2_service" {
  metadata {
    name      = "app2-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "app2"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}