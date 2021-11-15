variable "name" {
  type        = string
  description = "Name of the vnet to create"
}

variable "resource_group" {
  type        = string
  description = "Resource group name where the network will be deployed."
}

variable "location" {
  type        = string
  description = "Location where the network will be deployed."
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/20"]
}

# If no values specified, this defaults to Azure DNS
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.2.0/27"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = []
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(list(string))
  default = {
    "AMLSubnet" : ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "The tags to apply to the resources"
}
