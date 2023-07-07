resource "azurerm_container_registry" "acr" {
  name                = "skP20ContReg"
  resource_group_name = "PERSO_SIEF"
  location            = "westeurope"
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
