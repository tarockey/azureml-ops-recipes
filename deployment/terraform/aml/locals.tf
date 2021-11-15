locals {
  resource_prefix = lower("${var.project_code}-${var.env_code}")
}

locals {
  resource_group_name     = "${local.resource_prefix}-rg"
  storage_account_name    = replace("${local.resource_prefix}sto", "-", "")
  container_registry_name = replace("${local.resource_prefix}acr", "-", "")
  keyvault_name           = "${local.resource_prefix}-kv"
  log_analytics_name      = "${local.resource_prefix}-la"
  app_insights_name       = "${local.resource_prefix}-ain"
  vnet_name               = "${local.resource_prefix}-vnet"
  aml_name                = "${local.resource_prefix}-aml"
  bastion_host_name       = "${local.resource_prefix}-bastion"

  common_tags = {
    environment = var.env_code
    created-by  = data.azurerm_client_config.this.client_id
  }
}

locals {
  bastion_subnet_name    = "AzureBastionSubnet"
  bastion_subnet_address = "10.0.0.0/27"
  aml_subnet_name        = "AMLSubnet"
  aml_subnet_address     = "10.0.1.0/24"
  dsvm_subnet_name       = "DSVMSubnet"
  dsvm_subnet_address    = "10.0.2.0/24"
}
