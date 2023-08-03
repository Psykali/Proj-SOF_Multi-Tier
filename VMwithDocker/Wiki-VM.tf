####################
## Create Wiki VM ##
####################
resource "azurerm_linux_virtual_machine" "wiki_vm" {
  name                = var.wiki_vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B2ms"
  disable_password_authentication= false

network_interface_ids= [
    azurerm_network_interface.wiki_vm.id,
]

os_disk {
    caching              = "ReadWrite"
    storage_account_type= "Standard_LRS"
}

source_image_reference {
    publisher= "Canonical"
    offer    = "UbuntuServer"
    sku      = "20.04-LTS"
    version= "latest"
}

  admin_username= var.admin_username
  admin_password= var.admin_password

  tags = local.common_tags
}
##############################
## Create Network Interface ##
##############################
resource "azurerm_network_interface" "wiki_nic" {
  name = var.wiki_nic
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.wiki_ip
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wiki_pip.id
  }
  tags = local.common_tags
}
################################
## Create a public IP address ##
################################
resource "azurerm_public_ip" "wiki_pip" {
  name                = var.wiki_pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = var.wiki_vm
  tags = local.common_tags
}
###################
## SQL Databases ##
###################
resource "azurerm_mysql_database" "wiki_db" {
  name                = "wikidb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "UTF8"
  collation           = "UTF8_GENERAL_CI"
}
#######################################################################
####################
## Bash Scripting ##
####################
# Deploy Git Server
resource "null_resource" "install_packages" {
  depends_on = [
    azurerm_linux_virtual_machine.wiki_vm,
    azurerm_mysql_database.wiki_db,
  ]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.wiki_vm.public_ip_address
  }

provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get upgrade -y",
    "sudo apt-get install -y mysql-client",
    "mysql_config_editor set --login-path=azure_mysql --host=${azurerm_mysql_server.mysql.fqdn} --user=${azurerm_mysql_server.mysql.administrator_login} --password=${azurerm_mysql_server.mysql.administrator_login_password}",

  ]
}
}