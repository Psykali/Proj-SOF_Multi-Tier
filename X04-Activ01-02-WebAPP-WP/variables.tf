variable "location" {
  default = "francecentral"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "admin_username" {
  default = "SkLoginDipP20"
}

variable "admin_password" {
  default = "P@ssw0rd123P@ssw0rd123"
}

variable "app_service" {
  default = "skwp_webapp"
}

variable "sql_server_name" {
  default = "sksqldbservdprop20"
}

variable "sql_database_name" {
  default = "skdpprosqldb"
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