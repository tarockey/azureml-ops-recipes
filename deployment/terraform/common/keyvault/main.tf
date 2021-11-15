locals {
  tags = merge(var.tags,
    {
      "timestamp" = formatdate("MM/DD/YYYY hh:mm:ss", time_static.tag_timestamp.rfc3339)
  })
}

data "azurerm_client_config" "this" {}

data "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group
}

resource "time_static" "tag_timestamp" {
  triggers = {
    timestamp = var.name
  }
}

resource "azurerm_key_vault" "this" {
  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group
  tenant_id                = data.azurerm_client_config.this.tenant_id
  purge_protection_enabled = var.purge_protection_enabled
  soft_delete_enabled      = true
  sku_name                 = var.sku
  tags                     = local.tags

  network_acls {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [data.azurerm_subnet.this.id]
    bypass                     = "AzureServices"
  }

  # This enables access by the current client
  # This is needed for configuring KeyVault access policies
  access_policy {
    tenant_id = data.azurerm_client_config.this.tenant_id
    object_id = data.azurerm_client_config.this.object_id

    key_permissions = [
      "get",
      "create",
      "delete",
      "list",
      "restore",
      "recover",
      "unwrapkey",
      "wrapkey",
      "purge",
      "encrypt",
      "decrypt",
      "sign",
      "verify",
      "update"
    ]

    secret_permissions = [
      "set",
      "get",
      "list",
      "delete"
    ]
  }

  lifecycle {
    ignore_changes = [access_policy]
  }
}

# DNS Zones
resource "azurerm_private_dns_zone" "kv_zone" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group
}

# Linking of DNS zones to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "kv_zone_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link_kv"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.kv_zone[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
}

# Private Endpoint configuration
resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.resource_prefix}-kv-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = "${var.resource_prefix}-kv-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-kv"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_zone[count.index].id]
  }
}
