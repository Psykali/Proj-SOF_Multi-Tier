###############
## Create VM ##
###############
resource "azurerm_linux_virtual_machine" "clearenceai_vm" {
  name                = var.clearenceai_vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B2ms"
  disable_password_authentication= false

network_interface_ids= [
    azurerm_network_interface.clearenceai_nic.id,
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
resource "azurerm_monitor_metric_alert" "clearenceai_vm" {
  name                = "clearenceai-CPU"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.clearenceai_vm.id]
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
resource "azurerm_monitor_metric_alert" "clearenceaivm" {
  name                = "clearenceai-MeM"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_linux_virtual_machine.clearenceai_vm.id]
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
resource "azurerm_network_interface" "clearenceai_nic" {
  name = var.clearenceai_nic
  location = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.clearenceai_pip.id
  }
  tags = local.common_tags
}
################################
## Create a public IP address ##
################################
resource "azurerm_public_ip" "clearenceai_pip" {
  name                = var.clearenceai_pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "sklampwp"
  tags = local.common_tags
}
###################
## SQL Databases ##
###################
resource "azurerm_mysql_database" "clearenceai_db" {
  name                = "clearenceaidb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "UTF8"
  collation           = "UTF8_GENERAL_CI"
}
#######################################################################
####################
## Bash Scripting ##
####################
# Deploy ClearenceAI Server
resource "null_resource" "install_packages_gpt" {
  depends_on = [
    azurerm_linux_virtual_machine.clearenceai_vm,
    azurerm_mysql_database.clearenceai_db,
  ]

  connection {
    type     = "ssh"
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_linux_virtual_machine.clearenceai_vm.public_ip_address
  }

provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get upgrade -y",
    "sudo apt-get install -y git npm apt-transport-https ca-certificates curl software-properties-common",
    "sudo apt-get install -y mysql-client",
#    "mysql_config_editor set --login-path=azure_mysql --host=${azurerm_mysql_server.mysql.fqdn} --user=${azurerm_mysql_server.mysql.administrator_login} --password=${azurerm_mysql_server.mysql.administrator_login_password}",
    "sudo apt-get remove nodejs",
    "sudo apt-get remove npm",
    "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash",
    "chmod +x ~/.nvm/nvm.sh",
    "source ~/.bashrc",
    "nvm install 14",
    "nvm install 16",
    "nvm install 17",
    "nvm install 18",
    "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000",
     "sudo npm install -g n",
    "sudo n stable",
    "sudo npm install -g npm",
    "git clone https://github.com/mckaywrigley/clarity-ai.git",
#    "cd clarity-ai ",
#    "npm i ",
#    "npm audit fix",
#    "npm run dev",
  ]
  ## https://github.com/mckaywrigley/paul-graham-gpt
  ## https://github.com/mckaywrigley
  ## https://github.com/mckaywrigley/clarity-ai
  ## https://stackoverflow.com/questions/24750253/how-npm-start-runs-a-server-on-port-8000
  ## OpenAi API Key = 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
}
}