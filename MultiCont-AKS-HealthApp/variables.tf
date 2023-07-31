#####################
## Ressource Group ##
#####################
variable "location" {
  type        = string
  default = "francecentral"
}

variable "resource_group_name" {
  type        = string
  default = "PERSO_SIEF"
}
############
## Admin  ##
############
variable "admin_username" {
  type        = string
  default = "PsykProjsP20"
}

variable "admin_password" {
  type        = string
  default = "x*axbUNUeBJE^Jpwc%4*h"
}
#########################
## Container Registrey ##
#########################
variable "contreg_name" {
  type        = string
  default = "psykprojsacr"
}

variable "location_contreg" {
  type        = string
  default = "westeurope"
}

###############
## Azure AKS ##
###############
variable "kubernetes_cluster_name" {
  type        = string
  default = "psykprojsaks"
}

variable "dns_prefix" {
  type        = string
  default = "psykprojsaks"
}

variable "node_pool_name" {
  type        = string
  default = "psykprojspool"
}

variable "namespace_name" {
  type        = string
  default = "healthappli"
}