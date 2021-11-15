module "keyvault" {
  source = "../common/keyvault"

  resource_group             = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  name                       = local.keyvault_name
  sku                        = "standard"
  purge_protection_enabled   = true
  tags                       = local.common_tags
  resource_prefix            = local.resource_prefix
  vnet_name                  = local.vnet_name
  subnet_name                = local.aml_subnet_name
  enable_private_endpoint    = var.enable_private_endpoints

  depends_on = [module.vnet]
}
