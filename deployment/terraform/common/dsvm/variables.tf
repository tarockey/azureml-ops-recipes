variable "resource_group" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "dsvm_username" {
  type = string
}

variable "dsvm_password" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "security_rules" {
  description = "List of security rules for NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    source_address_prefix      = string
    destination_port_ranges     = list(string)
    destination_address_prefix = string
  }))
}
