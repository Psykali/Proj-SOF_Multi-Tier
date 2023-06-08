# Définir la version de Terraform et le fournisseur Azure
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}

# Créer un groupe de ressources
resource "azurerm_resource_group" "perso_sief" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

# Créer un réseau virtuel
resource "azurerm_virtual_network" "vnet" {
  name                = "skvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name
}

# Créer un sous-réseau
resource "azurerm_subnet" "subnet" {
  name                 = "sksnet"
  resource_group_name  = azurerm_resource_group.perso_sief.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Créer une adresse IP publique
resource "azurerm_public_ip" "lb_ip" {
  name                = "skpublicIPForLB"
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name
  allocation_method   = "Static"
}

# Créer un équilibreur de charge
resource "azurerm_lb" "lb" {
  name                = "skloadBalancer"
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name

  frontend_ip_configuration {
    name                 = "skpublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

# Créer un pool d'adresses backend pour l'équilibreur de charge
resource "azurerm_lb_backend_address_pool" "bepool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "skBackEndAddressPool"
}

# Créer une interface réseau pour chaque machine virtuelle
resource "azurerm_network_interface" "nic" {
  count               = 2
  name                = "sknic${count.index}"
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name

  ip_configuration {
    name                          = "sktestConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"

    # Associer l'interface réseau au pool d'adresses backend de l'équilibreur de charge
    load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.bepool.id]
  }
}

# Créer un ensemble de disponibilité pour les machines virtuelles
resource "azurerm_availability_set" "avset" {
  name                = "skavset"
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name
}

# Créer deux machines virtuelles Linux Debian avec XAMPP et WordPress installés dessus (IAAS)
resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 2
  name                  = "skvm${count.index}"
  location              = azurerm_resource_group.perso_sief.location
  availability_set_id   = azurerm_availability_set.avset.id
  resource_group_name   = azurerm_resource_group.perso_sief.name
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  size                  = "Standard_DS1_v2"

  admin_username = "testadmin"
  admin_password = "Password1234!"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }

  os_disk {
    name                 = "skosdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Installer XAMPP et WordPress en utilisant un script de provisionnement
  provisioner "file" {
    source      = "setup-xampp.sh"
    destination = "/tmp/setup-xampp.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-xampp.sh",
      "/tmp/setup-xampp.sh",
    ]
  }
}

# Créer un service de base de données MariaDB pour stocker les données du site web (PAAS)
resource "azurerm_mariadb_server" "db" {
  name                = "skmariadbserver"
  location            = azurerm_resource_group.perso_sief.location
  resource_group_name = azurerm_resource_group.perso_sief.name

  administrator_login          = "testadmin"
  administrator_login_password = "Password1234!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "10.3"

  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

# Créer une base de données MariaDB
resource "azurerm_mariadb_database" "db" {
  name                = "skwordpressdb"
  resource_group_name = azurerm_resource_group.perso_sief.name
  server_name         = azurerm_mariadb_server.db.name
  charset             = "utf8"
  collation           = "utf8_general
  }

output "wordpress_site_url" {
  value = "${azurerm_public_ip.lb_ip.ip_address}"
}