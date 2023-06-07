# Define the Azure provider
provider "azurerm" {
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "skrg" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

# Define the virtual network
resource "azurerm_virtual_network" "skvnet" {
  name                = "skvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
}

# Define the subnet for the VMs
resource "azurerm_subnet" "sksubnet" {
  name                 = "sksubnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.skvnet.name
  resource_group_name  = azurerm_resource_group.skrg.name
}

# Define the availability set for the VMs
resource "azurerm_availability_set" "skas" {
  name                = "skas"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name

  # Use a fault domain count of 2 and an update domain count of 5
  platform_fault_domain_count   = 2
  platform_update_domain_count  = 5
}

# Define the virtual machines
resource "azurerm_linux_virtual_machine" "skvm" {
  count                       = 2
  name                        = "skvm-${count.index}"
  location                    = azurerm_resource_group.skrg.location
  resource_group_name         = azurerm_resource_group.skrg.name
  availability_set_id         = azurerm_availability_set.skas.id
  size                        = "Standard_D2s_v3"
  admin_username              = "adminuser"
  network_interface_ids       = [azurerm_network_interface.sknic[count.index].id]
  os_disk {
    name                      = "skvm-os-disk-${count.index}"
    caching                   = "ReadWrite"
    storage_account_type      = "Standard_LRS"
  }
  source_image_reference {
    publisher                 = "Canonical"
    offer                     = "UbuntuServer"
    sku                       = "18.04-LTS"
    version                   = "latest"
  }
  custom_data = base64encode("${data.template_file.user_data_rendered.rendered}")
}

# Define the network interface for the VMs
resource "azurerm_network_interface" "sknic" {
  count                       = 2
  name                        = "sknic-${count.index}"
  location                    = azurerm_resource_group.skrg.location
  resource_group_name         = azurerm_resource_group.skrg.name
  ip_configuration {
    name                      = "skipconfig-${count.index}"
    subnet_id                 = azurerm_subnet.sksubnet.id
    private_ip_address        = "10.0.1.${count.index+1}"
    private_ip_address_allocation = "Static"
  }
}

# Define the load balancer
resource "azurerm_lb" "sklb" {
  name                = "sklb"
  location            = azurerm_resource_group.skrg.location
  resource_group_name = azurerm_resource_group.skrg.name
  frontend_ip_configuration {
    name                      = "sklb-feip"
    subnet_id                 = azurerm_subnet.sksubnet.id
  }
}

# Define the load balancer backend pool
resource "azurerm_lb_backend_address_pool" "skpool" {
  name                = "sklb-pool"
  loadbalancer_id     = azurerm_lb.sklb.id
  resource_group_name = azurerm_resource_group.skrg.name
}

# Add the VMs to the load balancer backend pool
resource "azurerm_lb_backend_address_pool_association" "skpool_assoc" {
  count                        = 2
  ip_configuration_name        = "skipconfig-${count.index}"
  loadbalancer_backend_address_pool_id = azurerm_lb_backend_address_pool.skpool.id
  network_interface_id         = azurerm_network_interface.sknic[count.index].id
  resource_group_name          = azurerm_resource_group.skrg.name
}

# Define the load balancer health probe
resource "azurerm_lb_probe" "skprobe" {
  name                = "sklb-probe"
  protocol            = "Tcp"
  port                = 80
  interval            = 15
  number_of_probes    = 2
  
  
  
## This code sets up a resource group, virtual network, subnet, availability set, virtual machines, network interfaces, load balancer, load balancer backend pool, load balancer backend pool association, and load balancer health probe in Azure using Terraform.
##The resources are named with "sk" + its acronym and the resource group is assumed to be already in place in France Central and named "PERSO_SIEF". 
