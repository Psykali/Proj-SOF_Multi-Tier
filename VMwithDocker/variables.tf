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
## VM pour Administer and developper
variable "admin_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "dev01psykprojs"
}
variable "admin_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "dev02psykprojs"
}
variable "admin_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "dev03psykprojs"
}
## VM pour deployer les sites web
variable "web_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "webpsykprojs"
}
## VM pour Docs 
variable "wiki_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "wikipsykprojs"
}

variable "wiki_admin_email" {
  description = "Value of the Wiki Admin Mail"
  type        = string
  default = "helahopahelahopa1@gmail.com"
}
variable "wiki_admin_password" {
  description = "Value of the Wiki Admin pass"
  type        = string
  default = "P@ssw0rd123P@ssw0rd1!2!3?"
}
## VM pour GitLabIntern
variable "gitlab_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "gitpsykprojs"
}
##VM pour GPT-AI locale
variable "clearenceai_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "clearenceaipsykprojs"
}
## VM Pour ChatServer and Etickting
variable "chattickting_vm" {
  description = "Value of the Ressource Group Locations"
  type        = string
  default = "clearenceaipsykprojs"
}
variable "rocketchat_mail_url" {
  default = ""
}
##                  ####
variable "rocketchat_root_url" {
  default = ""
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

variable "wordpress_01container_name" {
  description = "Value of the Vnet name"
  type        = string
  default = "wp01psyckprojs"
}
################
## SQL Server ##
################
variable "mysql_server_name" {
  description = "Value of the MySQL Serveur name"
  type        = string
  default = "sk-mysql-server"
}

variable "wordpress_01_database_name" {
  description = "Value of the WordPress DB name"
  type        = string
  default = "wp01"
}

variable "wiki_01_database_name" {
  description = "Value of the wikijs DB name"
  type        = string
  default = "wiki01"
}

variable "git_01_database_name" {
  description = "Value of the GitLab DB name"
  type        = string
  default = "git01"
}

variable "gpt_01_database_name" {
  description = "Value of the ClearenceAI DB name"
  type        = string
  default = "gpt01"
}

variable "virtualmin_01_database_name" {
  description = "Value of the Virtualmin DB name"
  type        = string
  default = "virtmin01"
}

variable "todoiest_01_database_name" {
  description = "Value of the ToDoiest DB name"
  type        = string
  default = "todoiest01"
}
#################
## PostGres DB ##
#################
variable "postgres_server_name" {
  description = "Value of the Postgres Serveur name"
  type        = string
  default = "sk-postgres-server"
}

variable "postgres_database_name" {
  description = "Value of the RocketCHat DB name"
  type        = string
  default = "rc01"
}