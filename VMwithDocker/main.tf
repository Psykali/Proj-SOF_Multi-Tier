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
      "sudo apt-get update && sudo apt-get -y upgrade",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo curl -L 'https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
    "sudo apt-key adv --fetch-keys 'https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/Quick_Install_Guide.gpg'",
    "sudo add-apt-repository 'deb [arch=amd64] https://repo.mysql.com/apt/ubuntu $(lsb_release -cs) mysql-8.0'",
    "sudo apt-get update",
    "sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password P@ssw0rd1234!'",
    "sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password P@ssw0rd1234!'",
    "sudo apt-get install -y mysql-server",
    "sudo systemctl start mysql",
    "sudo systemctl enable mysql",
    "sudo apt-get install -y python3-pip",  # Install pip for Python 3
    "sudo ln -s /usr/bin/python3 /usr/bin/python",  # Create a symbolic link for python command
    "sudo -H pip3 install --upgrade pip",  # Upgrade pip to the latest version
    "sudo -H pip3 install streamlit langchain openai wikipedia chromadb tiktoken",
  ]
  }
}