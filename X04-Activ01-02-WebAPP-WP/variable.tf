# Set variables
variable "location" {
  default = "francecentral"
}

variable "resource_group_name" {
  type = PERSO_SIEF
}

variable "webapp_name" {
  type = string
}

variable "sql_server_name" {
  default = "sksql"
}

variable "sql_database_name" {
  default = "wordpress"
}

variable "storage_account_name" {
  default = "sksawp"
}

variable "container_name" {
  default = "skwpimg"
}

variable "vm_name" {
  default = "sk-lamp-vm"
}

variable "admin_username" {
  default = "adminuser"
}

variable "admin_password" {
  default = "P@ssw0rd123"
}

##variable "app_insights_name" {
##  default = "skappinsights"
##}
##variable "app_insights_instrumentation_key" {
##  type = string
##}