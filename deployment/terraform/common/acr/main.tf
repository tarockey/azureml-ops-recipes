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

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = var.sku
  tags                = local.tags
  admin_enabled       = var.admin_enabled

  depends_on = [
    time_static.tag_timestamp
  ]
}
