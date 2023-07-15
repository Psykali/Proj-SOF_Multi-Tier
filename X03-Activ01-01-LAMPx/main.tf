data "azurerm_client_config" "current" {}

###########################################
## Create Resource Group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
###########################################
# Create VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.ubuntu-vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"
  disable_password_authentication= false

network_interface_ids= [
    azurerm_network_interface.nic.id,
]

os_disk {
    caching              = "ReadWrite"
    storage_account_type= "Standard_LRS"
}

source_image_reference {
    publisher= "Canonical"
    offer    = "UbuntuServer"
    sku      = "18.04-LTS"
    version= "latest"
}

admin_username= var.admin_username
admin_password= var.admin_password
}
## Networking
# Create Network Interface
resource "azurerm_network_interface" "default" {
  name = var.network_interface
  location = var.location
  resource_group_name = var.resource_group_name
}
# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name                = var.ubuntu-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
}
# Create NSG
resource "azurerm_network_security_group" "default" {
  name = var.network_security_group_name
  location = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name = "allow-http"
    priority = 100
    direction = "inbound"
    protocol = "tcp"
    source_port_range = "*"
    dest_port_range = "80"
    source_address_prefix = "*"
    dest_address_prefix = "*"
  }
}
# Create Subnet
resource "azurerm_subnet" "default" {
  name = var.subnet
  virtual_network_name = var.network_interface
  resource_group_name = var.resource_group_name
  address_prefixes = var.address_prefix
}
## Bash Scripting
# Deploy LAMP Server 
resource "null_resource" "install_lamp" {
  depends_on = [
    azurerm_virtual_machine.vm,
  ]
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2 php mysql-server php-mysql",
      "sudo service apache2 restart",
    ]
  }
}
# Install LAMP Server
resource "null_resource" "install_virtualmin" {
  depends_on = [
    azurerm_virtual_machine.vm,
  ]
  provisioner "remote-exec" {
    inline = [
      "wget http://download.virtualmin.com/install/virtualmin-install.sh",
      "chmod +x virtualmin-install.sh",
      "./virtualmin-install.sh",
    ]
  }
}