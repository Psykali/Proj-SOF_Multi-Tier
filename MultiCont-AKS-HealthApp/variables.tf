#####################
## Ressource Group ##
#####################
variable "location" {
  default = "francecentral"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}
############
## Admin  ##
############
variable "admin_username" {
  default = "PsykProjsP20"
}

variable "admin_password" {
  default = "x*axbUNUeBJE^Jpwc%4*h"
}
#########################
## Container Registrey ##
#########################
variable "contreg_name" {
  default = "psykprojs-acr"
}

variable "location_contreg" {
  description = "westeurope"
}

###############
## Azure AKS ##
###############
variable "kubernetes_cluster_name" {
  default = "psykprojs-aks"
}

variable "dns_prefix" {
  description = "psykprojs-aks"
}

variable "node_pool_name" {
  description = "psykprojs-agentpool"
}

variable "namespace_name" {
  description = "healthappli"
}