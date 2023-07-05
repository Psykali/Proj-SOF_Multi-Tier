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
    node_count      = 3
    vm_size         = "Standard_DS2_v2"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
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