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
    "sudo apt-get upgrade -y",
    "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
    "sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'",
    "sudo curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash",
    "sudo apt-get update",   
    "sudo debconf-set-selections <<< 'mariadb-server-10.6 mysql-server/root_password password P@ssw0rd1234!'",
    "sudo debconf-set-selections <<< 'mariadb-server-10.6 mysql-server/root_password_again password P@ssw0rd1234!'",
    "sudo apt-get install mariadb-server mariadb-client -y",
    "sudo systemctl start mariadb",
    "sudo systemctl enable mariadb",
    "sudo apt-get install -y python3-pip",
    "sudo ln -s /usr/bin/python3 /usr/bin/python",
    "sudo -H pip3 install --upgrade pip",
    "sudo -H pip3 install streamlit langchain openai wikipedia chromadb tiktoken",
  ]
}
}