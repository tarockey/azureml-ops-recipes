module "vnet" {
  source = "../common/vnet"

  name            = local.vnet_name
  resource_group  = azurerm_resource_group.this.name
  location        = azurerm_resource_group.this.location
  subnet_names    = [local.aml_subnet_name, local.bastion_subnet_name, local.dsvm_subnet_name]
  subnet_prefixes = [local.aml_subnet_address, local.bastion_subnet_address, local.dsvm_subnet_address]
  tags            = local.common_tags
}
