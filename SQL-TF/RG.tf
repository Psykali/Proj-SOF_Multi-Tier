###########################
## Create Resource Group
##########################
##resource "azurerm_resource_group" "rg" {
##  name     = var.resource_group_name
##  location = var.location
##}
##########
## Tags ##
##########
locals {
  common_tags = {
    CreatedBy = "SK"
    Env       = "Prod"
    Why       = "DipP20"
    Proj        = "Proj-Multitier"
    Infratype   = "PaaS-IaaS-IaC"
    Ressources  = "VM-WebApp-NSG-VNET-ContReg-Workbook-DockerImg"
  }
}