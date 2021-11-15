module "aml" {
  source = "../common/aml"

  resource_group               = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  name                         = local.aml_name
  log_analytics_workspace_name = local.log_analytics_name
  log_analytics_workspace_id   = var.log_analytics_workspace
  application_insights_name    = local.app_insights_name
  key_vault_name               = local.keyvault_name
  storage_account_name         = local.storage_account_name
  container_registry_name      = local.container_registry_name
  vnet_name                    = local.vnet_name
  subnet_name                  = local.aml_subnet_name
  enable_private_endpoint      = var.enable_private_endpoints
  tags                         = local.common_tags
  resource_prefix              = local.resource_prefix

  depends_on = [module.vnet, module.keyvault, module.storage, module.container_registry, module.log_analytics, module.application_insights]
}
