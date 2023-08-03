###############
## Create VM ##
###############
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.ubuntu-vm
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B2ms"
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
##############################
## Create Network Interface ##
##############################
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
################################
## Create a public IP address ##
################################
resource "azurerm_public_ip" "pip" {
  name                = var.ubuntu-pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  domain_name_label   = "sklampwp"
  tags = local.common_tags
}
#######################################################################
####################
## Bash Scripting ##
####################
# Deploy ClearenceAI Server
resource "null_resource" "install_packages" {
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
    "sudo apt-get install -y git npm apt-transport-https ca-certificates curl software-properties-common",
    "sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'",
    "sudo curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash",
    "sudo apt-get update",   
#    "echo 'mariadb-server-10.6 mysql-server/root_password password P@ssw0rd1234!' | sudo debconf-set-selections",
#    "echo 'mariadb-server-10.6 mysql-server/root_password_again password P@ssw0rd1234!' | sudo debconf-set-selections",
    "sudo apt-get install mariadb-server mariadb-client -y",
    "sudo systemctl start mariadb",
    "sudo systemctl enable mariadb",
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
    "cd clarity-ai ",
    "npm i ",
    "npm audit fix",
    "npm run dev",
  ]
  ## https://github.com/mckaywrigley/paul-graham-gpt
  ## https://github.com/mckaywrigley
  ## https://github.com/mckaywrigley/clarity-ai
  ## https://stackoverflow.com/questions/24750253/how-npm-start-runs-a-server-on-port-8000
  ## OpenAi API Key = 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
}
}