###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location_rg
##}
############################################################
# Create the container registry
resource "azurerm_container_registry" "acr" {
## name                = var.contreg_name
##  resource_group_name = var.resource_group_name
##  location            = var.location_contreg
  name                = "skP20ContReg"
  resource_group_name = "PERSO_SIEF"
  location            = "westeurope"
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Env = "Prod"
    Why = "DiplomeP20"
    CreatedBy = "SK"
    
  }
}