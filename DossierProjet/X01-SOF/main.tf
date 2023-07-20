locals {
  common_tags = {
    CreatedBy = "SK"
    Env       = "Prod"
    Why       = "DipP20"
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "h2ogpt-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "sk-h2ogpt-vm"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

provisioner "remote-exec" {
    inline = [
      # Update packages
      "sudo apt-get update",

      # Install dependencies
      "sudo apt-get install -y python3-pip git",

      # Clone the H2O GPT repository
      "git clone https://github.com/h2oai/h2ogpt.git",

      # Change to the h2ogpt directory
      "cd h2ogpt",

      # Install Python packages
      "pip3 install -r requirements.txt",
    ]
    connection {
        type     = "ssh"
        user     = var.admin_username
        password = var.admin_password
        host     = azurerm_public_ip.public_ip.ip_address
    }
}
}

## https://gpt.h2o.ai/
## https://www.youtube.com/watch?v=Coj72EzmX20