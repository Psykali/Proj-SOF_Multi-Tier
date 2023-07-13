###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.vm_name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${var.vm_name}-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

##      boot_diagnostics {
##        enabled     = true
##        storage_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
##      }
    }

resource "null_resource" "vm" {
  depends_on = [azurerm_virtual_machine.vm]

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.public_ip.ip_address
    user        = var.admin_username
    password    = var.admin_password
    agent       = false
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "rocket-chat-install.sh"
    destination = "/tmp/rocket-chat-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/rocket-chat-install.sh",
      "/tmp/rocket-chat-install.sh"
    ]
  }
}

##    resource "azurerm_storage_account" "storage_account" {
##     name                     = "${var.vm_name}diag"
##      resource_group_name      = var.resource_group_name
##      location                 = var.location
##      account_tier             = "Standard"
##      account_replication_type = "GRS"
##    }
##
##    resource "azurerm_backup_protected_vm" "backup_protected_vm" {
##      resource_group_name = var.resource_group_name
##      recovery_vault_name = azurerm_recovery_services_vault.recovery_services_vault.name
##      source_vm_id        = azurerm_virtual_machine.vm.id
##      backup_policy_id    = azurerm_backup_policy_vm.backup_policy_vm.id
##    }
##
##    resource "azurerm_recovery_services_vault" "recovery_services_vault" {
##      name                = "${var.vm_name}-recovery-vault"
##      location            = var.location
##      resource_group_name = var.resource_group_name
##      sku                 = "Standard"
##    }
##
##    resource "azurerm_backup_policy_vm" "backup_policy_vm" {
##      name                = "${var.vm_name}-backup-policy"
##      resource_group_name = var.resource_group_name
##      recovery_vault_name = azurerm_recovery_services_vault.recovery_services_vault.name
##
##      backup {
##        frequency = "Daily"
##        time      = "23:00"
##      }
##
##      retention_daily {
##        count = 30
##      }
##    }

    resource "azurerm_network_security_group" "nsg" {
      name                = "${var.vm_name}-nsg"
      location            = var.location
      resource_group_name = var.resource_group_name

      security_rule {
        name                       = "${var.vm_name}-http-rule"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }

    resource "azurerm_network_interface_security_group_association" "nsg_association" {
      network_interface_id      = azurerm_network_interface.nic.id
      network_security_group_id = azurerm_network_security_group.nsg.id
    }