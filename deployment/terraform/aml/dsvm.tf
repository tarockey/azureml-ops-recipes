module "dsvm" {
  source = "../common/dsvm"

  resource_group  = azurerm_resource_group.this.name
  location        = azurerm_resource_group.this.location
  tags            = local.common_tags
  resource_prefix = local.resource_prefix
  vnet_name       = local.vnet_name
  subnet_name     = local.dsvm_subnet_name
  dsvm_username   = "azureuser"
  dsvm_password   = "PasswordPassword!"
  vm_size         = "Standard_DS3_v2"
  security_rules = [
    {
        name                       = "AllowTCPFromBastion"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22","3389"]
        source_address_prefix      = local.bastion_subnet_address
        destination_address_prefix = "*"
    }
  ]

  depends_on = [module.vnet]
}
