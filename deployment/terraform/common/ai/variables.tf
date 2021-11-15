variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "application_type" {
  type    = string
  default = "web"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to associate to resources"
}
