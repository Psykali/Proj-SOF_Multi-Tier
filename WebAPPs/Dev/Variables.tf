#####################
## Ressource Group ##
#####################
variable "location" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "francecentral"
}

variable "location2" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "westeurope"
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
}

variable "admin_password" {
  description = "Value of the Admin Pass"
  type        = string
}

#######
variable "docker_registry_server_url" {
  description = "Docker registry server URL"
  type        = string
}

variable "docker_registry_server_user" {
  description = "Docker registry server user"
  type        = string
}

variable "docker_registry_server_password" {
  description = "Docker registry server password"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}