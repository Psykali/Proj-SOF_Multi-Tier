#########################
## Create WebServer VM ##
#########################
resource "azurerm_linux_virtual_machine" "chattickting_vm" {
  name                = var.chattickting_vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B2ms"
  disable_password_authentication= false

network_interface_ids= [
    azurerm_network_interface.chattickting_nic.id,
]

os_disk {
    caching              = "ReadWrite"
    storage_account_type= "Standard_LRS"
}

source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
}

  admin_username= var.admin_username
  admin_password= var.admin_password

  tags = local.common_tags
}
## Metrics and Alerts
resource "azurerm_monitor_metric_alert" "chattickting_vm" {
  name                = "chatticktingvm-CPU"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.chattickting_vm.id]
  description         = "Action will be triggered when CPU usage exceeds 80% for 5 minutes."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size        = "PT15M"
  frequency          = "PT5M"
}
resource "azurerm_monitor_metric_alert" "chatticktingvm" {
  name                = "chattickting-MeM"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.chattickting_vm.id]
  description         = "Action will be triggered when available memory falls below 20% for 5 minutes."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 0.2
  }

  window_size        = "PT15M"
  frequency          = "PT5M"
}
##############################
## Create Network Interface ##
##############################
resource "azurerm_network_interface" "chattickting_nic" {
  name = var.chattickting_nic
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = var.chattickting_ip
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.chattickting_pip.id
  }
  tags = local.common_tags
}
################################
## Create a public IP address ##
################################
resource "azurerm_public_ip" "chattickting_pip" {
  name                = var.chattickting_pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = var.chattickting_vm
  tags = local.common_tags
}
###################
## SQL Databases ##
###################
resource "azurerm_mysql_database" "chattickting_db" {
  name                = "chatticktingdb"
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
resource "null_resource" "install_packages_rocketchat_and_tickting" {
   depends_on = [
    azurerm_linux_virtual_machine.chattickting_vm,
    azurerm_mysql_database.chattickting_db,
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
        "sudo apt install -y git wget openssl",
        "sudo wget https://www.zulip.org/dist/releases/zulip-server-latest.tar.gz",
        "sudo tar -xvzf zulip-server-latest.tar.gz",
        "sudo -s ./zulip-server-*/scripts/setup/install --certbot --email=skhalifa@simplonformations.onmicrosoft.com --hostname=${azurerm_public_ip.chattickting_pip.fqdn}",     
  ]
}
}
