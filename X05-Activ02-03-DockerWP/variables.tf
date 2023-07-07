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