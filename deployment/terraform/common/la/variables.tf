variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "PerGB2018"
}

variable "retention_in_days" {
  type    = number
  default = 90
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to associate to resources"
}
