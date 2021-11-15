locals {
  tags = merge(var.tags,
    {
      "timestamp" = formatdate("MM/DD/YYYY hh:mm:ss", time_static.tag_timestamp.rfc3339)
  })
}

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

# Storage Account with VNET binding and Private Endpoint for Blob and File
resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = var.tier
  account_replication_type = var.replication_type
  is_hns_enabled           = var.is_hns_enabled
  min_tls_version          = "TLS1_2"

  tags = local.tags

  identity {
    type = "SystemAssigned"
  }
}

# Virtual Network & Firewall configuration
resource "azurerm_storage_account_network_rules" "firewall_rules" {
  count                = var.enable_private_endpoint ? 1 : 0
  resource_group_name  = var.resource_group
  storage_account_name = azurerm_storage_account.this.name

  default_action             = "Deny"
  ip_rules                   = []
  virtual_network_subnet_ids = [data.azurerm_subnet.this.id]
  bypass                     = ["AzureServices"]
}

# DNS Zones
resource "azurerm_private_dns_zone" "blob" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone" "file" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.resource_group
}

# Linking of DNS zones to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "blob_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link_blob"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.blob[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "file_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link_file"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.file[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
}

# Private Endpoint configuration
resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.resource_prefix}-sa-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = "${var.resource_prefix}-sa-psc-blob"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-blob"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob[count.index].id]
  }
}

resource "azurerm_private_endpoint" "file" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.resource_prefix}-sa-pe-file"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = "${var.resource_prefix}-sa-psc-file"
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.file[count.index].id]
  }
}
