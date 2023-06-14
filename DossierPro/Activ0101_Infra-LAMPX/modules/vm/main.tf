variable "resource_group_name" {}
variable "location" {}
variable "subnet_id" {}
variable "vm_name" {}
variable "lb_backend_pool_id" {}

resource "azurerm_network_interface" "skNIC" {
  name                = "${var.vm_name}NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
    load_balancer_backend_address_pool_ids = [var.lb_backend_pool_id]
  }
}

resource "azurerm_virtual_machine" "skVM" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.skNIC.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "${var.vm_name}OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11.0.0"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "PERSO_SIEF"
  }
}