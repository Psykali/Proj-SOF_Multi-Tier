##data "azurerm_client_config" "current" {}

locals {
  common_tags = {
    CreatedBy = "SK"
    Env       = "Prod"
    Why       = "DipP20"
  }
}
locals {
  dns_name = "${data.azurerm_public_ip.vm_public_ip.name}.cloudapp.azure.com"
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

#source_image_reference {
#    publisher= "Canonical"
#    offer    = "UbuntuServer"
#    sku      = "20.04-LTS"
#    version= "latest"
#}
 plan {
    publisher = "articentgroupllc1635512619530"
    product   = "wiki-js-wiki-engine-server-debian-11"
    name      = "wiki-js-wiki-engine-server-debian-11"
  }
  admin_username= var.admin_username
  admin_password= var.admin_password

  tags = local.common_tags
}
#######################################################################
#######################################################################
### Bash Scripting ###
#########################
### Installing Gitlab ###
######################### 
resource "null_resource" "update_gitlab_config" {
  provisioner "remote-exec" {
    inline = [
      #######################
### Install Updates ###
#######################
# Fetch latest updates
"sudo apt -qqy update && sudo apt upgrade -y",

###################################
### Installing the Dependencies ###
###################################
"sudo apt install ca-certificates curl openssh-server postfix tzdata perl",

#########################
### Installing Gitlab ###
#########################
"cd /tmp",
"curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh",
"sudo bash /tmp/script.deb.sh",
"sudo apt install gitlab-ce",
################
### FireWall ###
################
#sudo ufw allow http
#sudo ufw allow https
#sudo ufw allow OpenSSH

##########################
### Gitlab File Config ###
##########################
"sudo sed -i 's/http://your_domain/http://${local.dns_name}/' /etc/gitlab/gitlab.rb",
"sudo gitlab-ctl reconfigure"
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = data.azurerm_public_ip.vm_public_ip.ip_address
    }
  }
}
### Links: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu-20-04

# Deploy LAMP Server Ports 80, 443, 8050, 3306
#resource "null_resource" "install_wordpress" {
#  depends_on = [
#    azurerm_linux_virtual_machine.vm,
#  ]

#  connection {
 #   type     = "ssh"
#   user     = var.admin_username
#    password = var.admin_password
##    host     = azurerm_linux_virtual_machine.vm.public_ip_address
#  }

#provisioner "remote-exec" {
#    inline = [
      # Update packages
#      "sudo apt-get update",

      # Install Apache, PHP, and other dependencies
#      "sudo apt-get install -y apache2 php libapache2-mod-php php-mysql php-mbstring php-gd php-xml php-curl git",

      # Change to the /var/www/html directory
#     "cd /var/www/html",

      # Clone the Donut repository
#      "sudo git clone https://github.com/amiyasahu/Donut.git",

      # Change ownership of the Donut directory
 #     "sudo chown -R www-data:www-data /var/www/html/Donut",

      # Enable SSL and the default-ssl site in Apache
#      "sudo a2enmod ssl",
 #     "sudo a2ensite default-ssl",
#      "sudo systemctl reload apache2",

      # Create a virtual host for the Donut app on port 80
#      "

#}
#provisioner "remote-exec" {
#    inline = [
#      # Update packages
#      "sudo apt-get update",
#      "sudo apt-get upgrade -y ",
#      "sudo apt-get install -y apache2 curl git",
#      # Install Node.js
#      "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
#      "sudo apt-get install -y nodejs",
#      # Install MongoDB
#      "sudo apt-get install -y mongodb",
#      # Clone the Fullstack Chat repository
#      "git clone https://github.com/alamorre/fullstack-chat.git",
#      # Change to the fullstack-chat directory
#      "cd fullstack-chat",
#      # Install Node.js packages
#      "npm install",
#      # Start the application
#      "npm start",
#       # Start the application on port 8080
 ##     "PORT=8080 npm start &",
#    ]
#  connection {
#    type     = "ssh"
#    user     = var.admin_username
#    password = var.admin_password
#    host     = azurerm_linux_virtual_machine.vm.public_ip_address
#  }
# }
#}
## https://github.com/alamorre/fullstack-chat
## https://www.youtube.com/watch?v=Fzv-rgwcFKk
## https://www.youtube.com/watch?v=eXAvBN5tKfU&t=580s
## https://github.com/frdmn/docker-rocketchat/tree/master