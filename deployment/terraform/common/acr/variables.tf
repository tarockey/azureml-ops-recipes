variable "resource_group" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "Standard"
}

variable "tags" {
  type        = map(string)
  default     = {}
}

# This needs to default to true for use with AML
variable "admin_enabled" {
  type    = bool
  default = true
}
