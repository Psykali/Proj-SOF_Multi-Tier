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
  description = "sppersotfstates"
}

variable "blob_container_name" {
  type        = string
  description = "skpersotfstats"
}

variable "key_vault_name" {
  type        = string
  description = "sppersosecrets"
}

variable "key_vault_secret_name" {
  type        = string
  description = "hellovault"
}
