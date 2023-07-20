data "azurerm_client_config" "current" {}

locals {
  common_tags = {
    CreatedBy = "SK"
    Env       = "Prod"
    Why       = "DipP20"
  }
}
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
    azurerm_network_interface.default.id,
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

  tags = local.common_tags
}
#######################################################################
#######################################################################
## Bash Scripting
# Deploy LAMP Server Ports 80, 443, 8050, 3306
resource "null_resource" "install_wordpress" {
  depends_on = [
    azurerm_linux_virtual_machine.vm,
  ]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.vm.public_ip_address
  }

provisioner "remote-exec" {
   inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2 php libapache2-mod-php php-mysql php-mbstring php-gd php-xml php-curl git",
      "cd /var/www/html",
      "sudo git clone https://github.com/amiyasahu/Donut.git",
      "sudo chown -R www-data:www-data /var/www/html/Donut",
      "sudo service apache2 restart",
    ]
}
}