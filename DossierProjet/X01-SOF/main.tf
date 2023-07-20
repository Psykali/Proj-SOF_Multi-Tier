##data "azurerm_client_config" "current" {}

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
      # Update packages
      "sudo apt-get update",

      # Install Apache, PHP, and other dependencies
      "sudo apt-get install -y apache2 php libapache2-mod-php php-mysql php-mbstring php-gd php-xml php-curl git",

      # Change to the /var/www/html directory
      "cd /var/www/html",

      # Clone the Donut repository
      "sudo git clone https://github.com/amiyasahu/Donut.git",

      # Change ownership of the Donut directory
      "sudo chown -R www-data:www-data /var/www/html/Donut",

      # Enable SSL and the default-ssl site in Apache
      "sudo a2enmod ssl",
      "sudo a2ensite default-ssl",

      # Create a virtual host for the Donut app on port 80
      "echo '<VirtualHost *:80>' | sudo tee /etc/apache2/sites-available/donut.conf",
      "echo '  ServerName localhost' | sudo tee -a /etc/apache2/sites-available/donut.conf",
      "echo '  DocumentRoot /var/www/html/Donut' | sudo tee -a /etc/apache2/sites-available/donut.conf",
      "echo '</VirtualHost>' | sudo tee -a /etc/apache2/sites-available/donut.conf",
      "sudo a2ensite donut",

      # Restart the Apache service
      "sudo service apache2 restart",
    ]
}
provisioner "remote-exec" {
    inline = [
      # Update packages
      "sudo apt-get update",
      "sudo apt-get install -y curl",
      # Install Node.js
      "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      # Install MongoDB
      "sudo apt-get install -y mongodb",
      # Clone the Fullstack Chat repository
      "git clone https://github.com/alamorre/fullstack-chat.git",
      # Change to the fullstack-chat directory
      "cd fullstack-chat",
      # Install Node.js packages
      "npm install",
      # Start the application
      "npm start",
       # Start the application on port 8080
      "PORT=8080 npm start &",
    ]
  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.vm.public_ip_address
  }
}
}
## https://github.com/alamorre/fullstack-chat
## https://www.youtube.com/watch?v=Fzv-rgwcFKk