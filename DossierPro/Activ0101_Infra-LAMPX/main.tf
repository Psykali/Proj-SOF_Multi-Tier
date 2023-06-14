# Resource Group
resource "azurerm_resource_group" "PERSO_SIEF" {
  name     = "PERSO_SIEF"
  location = "France Central"
}

resource "azurerm_virtual_network" "skvnet" {
  name                = "skvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
}

resource "azurerm_subnet" "sksubnet" {
  name                 = "sksubnet"
  resource_group_name  = azurerm_resource_group.PERSO_SIEF.name
  virtual_network_name = azurerm_virtual_network.skvnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "skpublicip" {
  name                = "skpublicip"
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
}

resource "azurerm_lb" "sklb" {
  name                = "sklb"
  location            = azurerm_resource_group.PERSO_SIEF.location
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name

  frontend_ip_configuration {
    name                 = "skfrontendip"
    public_ip_address_id = azurerm_public_ip.skpublicip.id
  }

  backend_address_pool {
    name = "skbackendpool"
  }
}

resource "azurerm_lb_probe" "skhealthprobe" {
  name                = "skhealthprobe"
  resource_group_name = azurerm_resource_group.PERSO_SIEF.name
  loadbalancer_id     = azurerm_lb.sklb.id
  protocol            = "Tcp"
  port                = 80
}

resource "azurerm_lb_rule" "skloadbalancingrule" {
  name                           = "skloadbalancingrule"
  resource_group_name            = azurerm_resource_group.PERSO_SIEF.name
  loadbalancer_id                = azurerm_lb.sklb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.sklb.frontend_ip_configuration[0].name
  backend_address_pool_id        = azurerm_lb.sklb.backend_address_pool[0].id
  probe_id                       = azurerm_lb_probe.skhealthprobe.id
}

resource "azurerm_linux_virtual_machine" "skvm1" {
    name                  = "skvm1"
    location              = azurerm_resource_group.PERSO_SIEF.location
    resource_group_name   = azurerm_resource_group.PERSO_SIEF.name
    size                  = "Standard_B2s"
    admin_username        = var.admin_username
    admin_password        = var.admin_password
    network_interface_ids = [azurerm_network_interface.skvm1nic.id]

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher         = var.publisher
        offer             = var.offer
        sku               = var.sku
        version           = var.version
    }

    computer_name   ="${var.prefix}-vm1"
}

resource "azurerm_linux_virtual_machine" "skvm2" {
    name                  ="${var.prefix}-vm2"
    location              ="${var.location}"
    resource_group_name   ="${var.resourcegroup}"
    size                  ="${var.size}"
    admin_username        ="${var.admin_username}"
    admin_password        ="${var.admin_password}"
    network_interface_ids ="${azurerm_network_interface.skvm2nic.id}"

    os_disk {
        caching              ="ReadWrite"
        storage_account_type ="Standard_LRS"
    }

    source_image_reference {
        publisher         ="${var.publisher}"
        offer             ="${var.offer}"
        sku               ="${var.sku}"
        version           ="${var.version}"
    }

    computer_name