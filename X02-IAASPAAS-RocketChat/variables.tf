variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "location" {
  default = "francecentral"
}

variable "vnet_name" {
  default = "skrcvnet"
}

variable "subnet_name" {
  default = "skrcsubnet"
}

variable "mysql_server_admin_username" {
  default = "SkLoginDipP20"
}

variable "mysql_server_admin_password" {
  default = "P@ssw0rd123P@ssw0rd123"
}

variable "app_service_plan_name" {
  default = "sk-app-service-plan"
}

variable "app_service_sku" {
  default = "F1"
}

variable "mysql_server_name" {
  default = "sk-mysql-server"
}

variable "mysql_database_name" {
  default = "skproj02"
}

variable "zulip_app_name" {
  default = "sk-zulip-app"
}

variable "server_wiki_app" {
  default = "sk-wiki-app"
}
