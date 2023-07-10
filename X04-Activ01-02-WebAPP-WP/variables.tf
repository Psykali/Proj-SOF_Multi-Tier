variable "location" {
  default = "francecentral"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "admin_username" {
  default = "skwp_admin"
}

variable "admin_password" {
  default = "P@ssw0rd123H@Sh1CoR3!"
}

variable "app_service" {
  default = "skwp_webapp"
}

variable "sql_server_name" {
  default = "skwp_sqlserver"
}

variable "sql_database_name" {
  default = "skwp_sqldb"
}

variable "storage_account_name" {
  default = "skwp_storage"
}

variable "container_name" {
  default = "skwp_blobcontainer"
}

variable "app_service_plan" {
  default = "skwp_appplan"
}