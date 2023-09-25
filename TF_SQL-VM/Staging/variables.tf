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
########
## VM ##
########
## VM pour Administer and developper
variable "admin__vm" {
  description = "Value of the Dev 01 VM"
  type        = string
  default = "StagingSQL"
}
################
## Networking ##
################
variable "subnet_name" {
  description = "Value of the Subnet name"
  type        = string
  default = "staging-subnet"
}

variable "virtual_network_name" {
  description = "Value of the Vnet name"
  type        = string
  default = "skdb-vnet"
}

variable "network_security_group_name" {
  description = "Value of the NSG name"
  type        = string
  default = "skdb-nsg"
}
## Administer and developper
variable "admin_nic" {
  description = "Value of the admin NIC name"
  type        = string
  default = "staging-sqlnic"
}
variable "admin_pip" {
  description = "Value of the admin Public IP name"
  type        = string
  default = "staging-sqlpip"
}
variable "admin_ip" {
  description = "Value of the admin Public IP name"
  type        = string
  default = "staging-sqlip"
}
