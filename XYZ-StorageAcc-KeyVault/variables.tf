variable "resource_group_name" {
  type        = string
  description = "PERSO_SIEF"
}

variable "location" {
  type        = string
  description = "francecentral"
}

variable "storage_account_name" {
  type        = string
  description = "skpersop20tfsa"
}

variable "blob_container_name" {
  type        = string
  description = "helloblob"
}

variable "key_vault_name" {
  type        = string
  description = "skpersokv"
}

variable "key_vault_secret_name" {
  type        = string
  description = "hellovault"
}
