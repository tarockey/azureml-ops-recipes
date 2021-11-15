module "bastion" {
  source = "../common/bastion"

  resource_group             = azurerm_resource_group.this.name
  location                   = azurerm_resource_group.this.location
  name                       = local.bastion_host_name
  tags                       = local.common_tags
  resource_prefix            = local.resource_prefix
  vnet_name                  = local.vnet_name
  subnet_name                = local.bastion_subnet_name

  depends_on = [module.vnet]
}
