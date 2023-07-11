variable "location" {
  default = "westeurope"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "admin_username" {
  default = "skwp_admin"
}

variable "admin_password" {
  default = "P@ssw0rd123"
}

variable "container_name" {
  default = "skdrcp20"
}

variable "image_name" {
  default = "skp20contreg.azurecr.io/rocketchat:latest"
}

##variable "scope_map_token_name" {
##  default = "docker login -u Admin -p Zxq1EiAjiDl3BEDNbRXBzrjN7szlmJ+DLtdFe63Vn4+ACRCPwHZC skp20contreg.azurecr.io"
##}

variable "scope_map_token_name" {
  default = "Admin"
}

variable "scope_map_token_password" {
  default = "Zxq1EiAjiDl3BEDNbRXBzrjN7szlmJ+DLtdFe63Vn4+ACRCPwHZC"
}