#####################
## Ressource Group ##
#####################
variable "location" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "francecentral"
}

variable "resource_group_name" {
  description = "Value of the Ressource Group name"
  type        = string
  default = "PERSO_SIEF"
}
############
## Admin  ##
############
variable "admin_username" {
  description = "Value of the Admin login"
  type        = string
  default = "SkLoginDipP20"
}

variable "admin_password" {
  description = "Value of the Admin Pass"
  type        = string
  default = "V83phJJDRExKW3kmhLCm4"
}
#######
variable "docker_registry_server_url" {
  description = "Value of the Admin Pass"
  type        = string
  default = "skp20contreg.azurecr.io"
}
variable "docker_registry_server_user" {
  description = "Value of the Admin Pass"
  type        = string
  default = "skP20ContReg"
}
variable "docker_registry_server_password" {
  description = "Value of the Admin Pass"
  type        = string
  default = "y+vwH2D7QqUE3VHrBTz+hsMAUejMduPjug7E40Alau+ACRCytZmV"
}