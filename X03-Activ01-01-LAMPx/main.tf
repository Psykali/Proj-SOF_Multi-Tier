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

## Create Backup
resource "azurerm_recovery_services_vault" "recovery_vault" {
  name                = "skrv"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_recovery_services_backup_policy_vm" "backup_policy" {
  name                = "skrvpolicy"
  resource_group_name = var.resource_group_name
  backup_policy {
    frequency = "Daily"
    time      = "23:00"
    retention_daily {
      count = 5
    }
  }
  operation_mode = "Complete"
}

resource "azurerm_recovery_services_protected_vm" "protected_vm" {
  resource_group_name     = var.resource_group_name
  recovery_vault_name     = azurerm_recovery_services_vault.recovery_vault.name
  source_vm_id            = azurerm_linux_virtual_machine.vm.id
  backup_policy_id        = azurerm_recovery_services_backup_policy_vm.backup_policy.id
}

resource "azurerm_recovery_services_protection_policy_vm" "recovery_vault_policy" {
  name                = var.recovery_vault_protection_policy_name
  resource_group_name = azurerm_resource_group.recovery_vault_rg.name
  backup {
    retention_duration {
      count = 5
      type  = "Days"
    }
  }

  azure_vm_resource_id          = azurerm_linux_virtual_machine.vm.id
  source_vm_storage_type_to_use = "GRS"

## Networking
## Creat Vnet
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/8"]
  tags = local.common_tags
}

# Create Network Interface
resource "azurerm_network_interface" "default" {
  name = var.network_interface
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
  tags = local.common_tags
}
# Create a public IP address
resource "azurerm_public_ip" "pip" {
  name                = var.ubuntu-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "sklampwp"
  tags = local.common_tags
}
# Create NSG
resource "azurerm_network_security_group" "default" {
  name = var.network_security_group_name
  location = var.location
  resource_group_name = var.resource_group_name

security_rule {
  name                   = "allow-http"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "80,8080"
  source_address_prefix  = "*"
  destination_address_prefix= "*"
}

  tags = local.common_tags

}
# Create Subnet
resource "azurerm_subnet" "default" {
  name                 = var.subnet
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.1.0/24"]
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
    "sudo apt-get install -y curl apache2 php libapache2-mod-php mysql-server php-mysql",
    "cd /tmp",
    "curl -O https://wordpress.org/latest.tar.gz",
    "tar xzvf latest.tar.gz",
    "sudo cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php",
    "sudo sed -i 's/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '127.0.0.1:3306' );/' /tmp/wordpress/wp-config.php",
    "sudo cp -a /tmp/wordpress/. /var/www/html",
    "sudo chown -R www-data:www-data /var/www/html",
    "sudo sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf",
    "sudo sed -i 's/<VirtualHost \\*:80>/<VirtualHost \\*:8080>/' /etc/apache2/sites-available/000-default.conf",
    "sudo service apache2 restart",
  ]
}
}
