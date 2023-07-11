###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
############################################################
##resource "azurerm_container_registry" "acr" {
##    name                = "rocketcatacr"
##    resource_group_name = var.resource_group_name
##    location            = var.location
##    sku                 = "Basic"
##    admin_enabled       = true
##}
#############################################################
resource "azurerm_container_group" "cg" {
    name                = "sk-rocketcat-cg"
    location            = var.location
    resource_group_name = var.resource_group_name
    ip_address_type     = "public"
    dns_name_label      = "rocketcat-dns"
    os_type             = "Linux"

    container {
        name   = var.container_name
        image  = var.image_name
        cpu    = "0.5"
        memory = "1.5"

        ports {
            port     = 80
            protocol = "TCP"
        }
    }

    image_registry_credential {
    server   = "skp20contreg.azurecr.io"
    username = var.scope_map_token_name
    password = var.scope_map_token_password
  }
}