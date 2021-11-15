variable "name" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "location" {
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
  default = [
    {
        name                       = "GatewayManager"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = ["443"]
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
    },
    {
      name                       = "AzureCloud"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      source_address_prefix      = "AzureCloud"
      destination_port_ranges     = ["443"]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHttps"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = ["443"]
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
    },
    {
        name                       = "OutboundVirtualNetwork"
        priority                   = 100
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22","3389"]
        source_address_prefix      = "*"
        destination_address_prefix = "VirtualNetwork"
    },
    {
        name                       = "OutboundToAzureCloud"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges     = ["443"]
        source_address_prefix      = "*"
        destination_address_prefix = "AzureCloud"
    }
  ]
}
