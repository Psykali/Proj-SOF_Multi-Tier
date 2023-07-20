#####################
## Ressource Group ##
#####################
variable "resource_group_name" {
  default = "PERSO_SIEF"
}
####
variable "location" {
  default = "francecentral"
}
################
## Networking ##
################
variable "vnet_name" {
  default = "skrcvnet"
}
####
variable "subnet_name" {
  default = "skrcsubnet"
}
################
## SQL Server ##
################
variable "mysql_server_name" {
 default = "sk-mysql-server"
}

variable "mysql_server_admin_username" {
  default = "SkLoginDipP20"
}

variable "mysql_server_admin_password" {
  default = "P@ssw0rd123P@ssw0rd123"
}
####
variable "mysql_database_name" {
  default = "skproj02"
}
####
variable "mysql_database_name" {
  default = "skproj02"
}
##################
## Service Plan ##
##################
variable "app_service_plan_name" {
  default = "sk-app-service-plan"
}
####
variable "app_service_sku" {
  default = "F1"
}
####
variable "zulip_app_name" {
  default = "sk-zulip-app"
}
####
variable "server_wiki_app" {
  default = "sk-wiki-app"
}
#################
## PostGres DB ##
#################
##variable "postgres_server_name" {
##  default = "sk-postgres-server"
##}
######
##variable "postgres_admin_username" {
##  default = "SkLoginDipP20"
##}
######
##variable "postgres_admin_password" {
##  default = "P@ssw0rd123P@ssw0rd123"
##}
######
##variable "postgres_database_name" {
##  default = "skprojpg02"
##}
#################
## Cosmos DB ##
#################
variable "postgres_server_name" {
  default = "sk-postgres-server"
} 
#################
## RocketChat ##
#################
variable "rocketchat_app_name" {
  default = "sk-rc"
}
##                  ####
variable "rocketchat_mail_url" {
  default = ""
}
##                  ####
variable "rocketchat_root_url" {
  default = ""
} 
###########
## Redis ##
###########
##variable "redis_name" {
##  default = "sk-redis-server"
##}