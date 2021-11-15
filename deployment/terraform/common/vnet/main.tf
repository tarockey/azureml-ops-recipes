locals {
  tags = merge(var.tags,
    {
      "timestamp" = formatdate("MM/DD/YYYY hh:mm:ss", time_static.tag_timestamp.rfc3339)
  })
}

resource "time_static" "tag_timestamp" {
  triggers = {
    timestamp = var.name
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  count                                          = length(var.subnet_names)
  name                                           = var.subnet_names[count.index]
  resource_group_name                            = var.resource_group
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = [var.subnet_prefixes[count.index]]
  service_endpoints                              = lookup(var.subnet_service_endpoints, var.subnet_names[count.index], null)
  enforce_private_link_endpoint_network_policies = true
}
