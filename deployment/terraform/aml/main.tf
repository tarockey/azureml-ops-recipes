provider "azurerm" {
  version = "=2.85"
  features {
  }
}

data "azurerm_client_config" "this" {
}

resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}
