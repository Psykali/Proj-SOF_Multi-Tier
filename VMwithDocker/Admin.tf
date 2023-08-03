
#####################
## Create Admin VM ##
#####################
resource "azurerm_linux_virtual_machine" "admin__vm" {
  count               = 3
  name                = "${var.admin__vm}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B2ms"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.admin_nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer    = "UbuntuServer"
    sku      = "20.04-LTS"
    version  = "latest"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  tags = local.common_tags
}
##############################
## Create Network Interface ##
##############################
resource "azurerm_network_interface" "admin_nic" {
  count               = 3
  name                = "${var.admin_nic}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.admin_pip[count.index].id
  }

  tags = local.common_tags
}
################################
## Create a public IP address ##
################################
resource "azurerm_public_ip" "admin_pip" {
  count               = 3
  name                = "${var.admin_pip}-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.admin__vm}-${count.index}"
  tags                = local.common_tags
}
#######################################################################
####################
## Bash Scripting ##
####################
# Deploy Git Server
resource "null_resource" "install_packages" {
  depends_on = [
    azurerm_linux_virtual_machine.gitlab_vm,
  ]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.gitlab_vm.public_ip_address
  }

provisioner "remote-exec" {
  inline = [
        "sudo apt-get update && sudo apt-get -y upgrade", 
        "sudo apt update && sudo apt -y upgrade",
        "sudo apt-get install -y apache2",
        "sudo apt-get install -y mariadb-server",
        "sudo apt-get install -y php libapache2-mod-php php-mysql",
        "sudo apt -y install docker.io",
        "sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose",
        "sudo chmod +x /usr/local/bin/docker-compose",
  ]
}
}

