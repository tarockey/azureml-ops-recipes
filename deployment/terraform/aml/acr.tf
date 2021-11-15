module "container_registry" {
  source = "../common/acr"

  resource_group = azurerm_resource_group.this.name
  location       = azurerm_resource_group.this.location
  name           = local.container_registry_name
  tags           = local.common_tags
  admin_enabled  = true
}
