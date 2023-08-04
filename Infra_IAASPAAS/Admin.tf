
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username = var.admin_username
  admin_password = var.admin_password

  tags = local.common_tags
}
## Metrecs and Alerts
resource "azurerm_monitor_metric_alert" "admin__vm" {
  name                = "adminvm-CPU"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.admin__vm[0].id]
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
resource "azurerm_monitor_metric_alert" "admin_vm" {
  name                = "adminvm-MeM"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.admin__vm[0].id]
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
###################
## SQL Databases ##
###################
resource "azurerm_mysql_database" "admin_db" {
  count               = 3
  name                = "admindb-${count.index}"
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
resource "null_resource" "install_packages_for_the_devs" {
 count = 3

  depends_on = [
    azurerm_linux_virtual_machine.admin__vm,
    azurerm_mysql_database.admin_db,
  ]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = element(azurerm_linux_virtual_machine.admin__vm.*.public_ip_address, count.index)
  }

provisioner "remote-exec" {
  inline = [
      "sudo apt-get update && sudo apt-get -y upgrade", 
      "sudo apt update && sudo apt -y upgrade",
      "sudo apt-get install -y apache2",
      "sudo apt-get install -y mariadb-server",
      "sudo apt-get install -y php libapache2-mod-php php-mysql",
      "sudo apt -y install docker.io",
      "sudo curl -L 'https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo apt-get install -y mysql-client",
#      "mysql_config_editor set --login-path=azure_mysql --host=${azurerm_mysql_server.mysql.fqdn} --user=${azurerm_mysql_server.mysql.administrator_login} --password=${azurerm_mysql_server.mysql.administrator_login_password}",
    ]
}
}

