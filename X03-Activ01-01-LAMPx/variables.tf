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
  default = "P@ssw0rd123P@ssw0rd123"
}

variable "ubuntu-vm" {
  default = "skwpp20mdb"
}

variable "subnet" {
  default = "skwpp20subnet"
}

variable "virtual_network" {
  default = "skwpp20vnet"
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

variable "address_prefix" {
  type = string
  description = "10.0.1.0/24"
}