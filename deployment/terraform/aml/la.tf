module "log_analytics" {
  source = "../common/la"

  name           = local.log_analytics_name
  resource_group = azurerm_resource_group.this.name
  location       = azurerm_resource_group.this.location
  tags           = local.common_tags
}