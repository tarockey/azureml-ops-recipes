variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "tier" {
  type    = string
  default = "Standard"
}

variable "replication_type" {
  type    = string
  default = "LRS"
}

variable "is_hns_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
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
