variable "resource_group" {
  type = string
}

variable "name" {
  description = "The name of the Keyvault"
  type        = string
}

variable "location" {
  type = string
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Is Purge Protection enabled for this Key Vault?"
}

variable "sku" {
  type        = string
  default     = "standard"
  description = <<EOF
    The Name of the SKU used for this Key Vault.
    Possible values are standard and premium.
  EOF
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to apply to the resources"
}

variable "enable_private_endpoint" {
  type    = bool
  default = false
}

variable "vnet_name" {
  type    = string
}

variable "subnet_name" {
  type    = string
}

variable "resource_prefix" {
  type    = string
  default = ""
}