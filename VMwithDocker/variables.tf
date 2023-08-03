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
}

variable "admin_password" {
  description = "Value of the Admin Pass"
  type        = string
}
########
## VM ##
########
variable "admin_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "adminpsykprojs"
}

variable "web_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "webpsykprojs"
}

variable "wiki_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "wikipsykprojs"
}

variable "gitlab_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "gitpsykprojs"
}

variable "clearenceai_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "clearenceaipsykprojs"
}
################
## Networking ##
################
variable "subnet_name" {
  description = "Value of the Subnet name"
  type        = string
  default = "subnetpsyckprojs"
}

variable "virtual_network_name" {
  description = "Value of the Vnet name"
  type        = string
  default = "vnetpsyckprojs"
}

variable "network_interface_name" {
  description = "Value of the NIC name"
  type        = string
  default = "nicpsyckprojs"
}

variable "network_security_group_name" {
  description = "Value of the NSG name"
  type        = string
  default = "nsgpsyckprojs"
}

variable "public_ip_name" {
  description = "Value of the Public IP name"
  type        = string
  default = "pippsyckprojs"
}

variable "load_balancer_name" {
  description = "Value of the Load Balancer name"
  type        = string
  default = "lbpsyckprojs"
}
#####################
## Storage Account ##
#####################
variable "storage_account_name" {
  description = "Value of the Storage Account name"
  type        = string
  default = "sapsyckprojs"
}

variable "container_name" {
  description = "Value of the Vnet name"
  type        = string
  default = "wppsyckprojs"
}