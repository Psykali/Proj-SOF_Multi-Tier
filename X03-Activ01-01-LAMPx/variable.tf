# Define variables
variable "resource_group_name" {
  default = "PERSO_SIEF"
}

variable "location" {
  default = "francecentral"
}

variable "vm_name" {
  default = "sk-lamp-vm"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {
  default = "adminuser"
}

variable "admin_password" {
  default = "P@ssw0rd123"
}

variable "app_insights_name" {
  default = "skappinsights"
}