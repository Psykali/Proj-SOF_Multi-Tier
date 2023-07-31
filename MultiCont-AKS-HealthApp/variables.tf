#####################
## Ressource Group ##
#####################
variable "location" {
  default = "francecentral"
}

variable "location_contreg" {
  description = "westeurope"
}

variable "resource_group_name" {
  default = "PERSO_SIEF"
}
############
## Admin  ##
############
variable "admin_username" {
  default = "SkLoginDipP20"
}

variable "admin_password" {
  default = "P@ssw0rd123P@ssw0rd123"
}
########
## VM ##
########
variable "ubuntu-vm" {
  default = "skwpp20lamp"
}
################
## Networking ##
################
variable "subnet" {
  default = "skwpp20subnet"
}

variable "virtual_network_name" {
  default = "skwpp20vnet"
}

variable "virtual_network" {
  default = "skwpp20net"
}

variable "network_interface" {
  default = "skwpp20nic"
}

variable "network_security_group_name" {
  default = "skwpp20nsg"
}

variable "ubuntu-ipconfig" {
  default = "skwpp20ip"
}

variable "ubuntu-pip" {
  default = "skwpp20pip"
}