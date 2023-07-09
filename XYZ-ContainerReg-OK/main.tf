###########################################################
### Create the resource group
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location_rg
##}
############################################################
# Create the container registry
resource "azurerm_container_registry" "acr" {
  name                = var.contreg_name
  resource_group_name = var.resource_group_name
  location            = var.location_contreg
  sku                 = "Basic"
  admin_enabled       = true
}

#resource "null_resource" "acr_import" {
#  provisioner "local-exec" {
#    command = <<EOT
#      az login --service-principal -u $${ARM_CLIENT_ID} -p $${ARM_CLIENT_SECRET} --tenant $${ARM_TENANT_ID} 
#      az acr login --name ${azurerm_container_registry.acr.name}
#      az acr import --name ${azurerm_container_registry.acr.name} --source docker.io/library/wordpress:latest --image wordpress:latest
#      az acr import --name ${azurerm_container_registry.acr.name} --source docker.io/rocketchat/rocket.chat:latest --image rocketchat:latest
#      az acr import --name ${azurerm_container_registry.acr.name} --source docker.io/psykali/stackoverp20kcab:latest --image psykali/stackoverp20kcab:latest
#    EOT
#  }
#}
