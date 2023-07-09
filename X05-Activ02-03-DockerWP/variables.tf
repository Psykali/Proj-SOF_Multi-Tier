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

variable "sql_server_name" {
  default = "skwpp20-sqlserver"
}

variable "sql_database_name" {
  default = "skwp-sqldb"
}

variable "container_name" {
  default = "skdwpp20cont"
}

variable "image_name" {
  default = "skp20contreg.azurecr.io/wordpress:latest"
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