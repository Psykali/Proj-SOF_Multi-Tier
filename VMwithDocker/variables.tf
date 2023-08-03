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
  default = "admin"
}
## VM pour deployer les sites web
variable "web_vm" {
  description = "Value of the Web VM"
  type        = string
  default = "webpsykprojs"
}
## VM pour Docs 
variable "wiki_vm" {
  description = "Value of the Wiki Locale"
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
## GitLab Intern
variable "gitlab_vm" {
  description = "Value of the GitLab Intern"
  type        = string
  default = "gitpsykprojs"
}
## GPT-AI locale
variable "clearenceai_vm" {
  description = "Value of the GPT-AI Locale"
  type        = string
  default = "clearenceaipsykprojs"
}
## ChatServer and Etickting
variable "chattickting_vm" {
  description = "Value of the RocketChat and E-Tickting VM"
  type        = string
  default = "rcpsykprojs"
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

variable "network_security_group_name" {
  description = "Value of the NSG name"
  type        = string
  default = "nsgpsyckprojs"
}

variable "load_balancer_name" {
  description = "Value of the Load Balancer name"
  type        = string
  default = "lbpsyckprojs"
}
## GPT-AI locale
variable "clearenceai_nic" {
  description = "Value of the GPT-AI NIC name"
  type        = string
  default = "clearenceainic"
}
variable "clearenceai_pip" {
  description = "Value of the GPT-AI Public IP name"
  type        = string
  default = "clearenceaiip"
}
variable "clearenceai_ip" {
  description = "Value of the GPT-AI Public IP name"
  type        = string
  default = "clearenceaiip"
}
## GitLab Intern
variable "gitlab_nic" {
  description = "Value of the GitLab Intern NIC name"
  type        = string
  default = "gitnic"
}
variable "gitlab_pip" {
  description = "Value of the GitLab Intern Public IP name"
  type        = string
  default = "gitpip"
}
variable "gitlab_ip" {
  description = "Value of the GitLab Intern Public IP name"
  type        = string
  default = "gitip"
}
## VM pour Docs
variable "wiki_nic" {
  description = "Value of the VM pour Docs NIC name"
  type        = string
  default = "wikinic"
}
variable "wiki_pip" {
  description = "Value of the VM pour Docs Public IP name"
  type        = string
  default = "wikipip"
}
variable "wiki_ip" {
  description = "Value of the VM pour Docs Public IP name"
  type        = string
  default = "wikiip"
}
## ChatServer and Etickting
variable "chattickting_nic" {
  description = "Value of the RocketChat and E-Tickting NIC name"
  type        = string
  default = "rcnic"
}
variable "chattickting_pip" {
  description = "Value of the RocketChat and E-Tickting Public IP name"
  type        = string
  default = "rcpip"
}
variable "chattickting_ip" {
  description = "Value of the RocketChat and E-Tickting Public IP name"
  type        = string
  default = "rcip"
}
## VM pour deployer les sites web
variable "web_nic" {
  description = "Value of the web NIC name"
  type        = string
  default = "webnic"
}
variable "web_pip" {
  description = "Value of the web Public IP name"
  type        = string
  default = "webpip"
}
variable "web_ip" {
  description = "Value of the web Public IP name"
  type        = string
  default = "webip"
}
## Administer and developper
variable "admin_nic" {
  description = "Value of the admin NIC name"
  type        = string
  default = "adminnic"
}
variable "admin_pip" {
  description = "Value of the admin Public IP name"
  type        = string
  default = "adminpip"
}
variable "admin_ip" {
  description = "Value of the admin Public IP name"
  type        = string
  default = "adminip"
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