locals {
  tags = merge(var.tags,
    {
      "timestamp"  = formatdate("MM/DD/YYYY hh:mm:ss", time_static.tag_timestamp.rfc3339)
  })
}

resource "time_static" "tag_timestamp" {
  triggers = {
    timestamp = var.name
  }
}

resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = var.application_type
  tags                = local.tags
}
