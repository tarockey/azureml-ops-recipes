locals {
  tags = merge(var.tags,
    {
      "timestamp" = formatdate("MM/DD/YYYY hh:mm:ss", time_static.tag_timestamp.rfc3339)
  })
}

data "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group
}

data "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group
}

data "azurerm_key_vault" "this" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group
}

data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group
}

data "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group
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

resource "azurerm_machine_learning_workspace" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group
  application_insights_id = data.azurerm_application_insights.this.id
  key_vault_id            = data.azurerm_key_vault.this.id
  storage_account_id      = data.azurerm_storage_account.this.id
  container_registry_id   = data.azurerm_container_registry.this.id
  tags                    = local.tags

  identity {
    type = "SystemAssigned"
  }
}

# Create Compute Resources in AML
resource "null_resource" "compute_cluster" {
  provisioner "local-exec" {
    command = "az ml computetarget create amlcompute --max-nodes 4 --min-nodes 0 --name cpu-cluster --vm-size Standard_DS3_v2 --idle-seconds-before-scaledown 600 --assign-identity [system] --vnet-name ${data.azurerm_subnet.this.virtual_network_name} --subnet-name ${data.azurerm_subnet.this.name} --vnet-resourcegroup-name ${var.resource_group} --resource-group ${var.resource_group} --workspace-name ${azurerm_machine_learning_workspace.this.name}"
  }

  depends_on = [azurerm_machine_learning_workspace.this]
}

# DNS Zones
resource "azurerm_private_dns_zone" "ws_zone_api" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.api.azureml.ms"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone" "ws_zone_notebooks" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.notebooks.azure.net"
  resource_group_name = var.resource_group
}

# Linking of DNS zones to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_api_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link_api"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_api[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ws_zone_notebooks_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "link_notebooks"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.ws_zone_notebooks[count.index].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
}

# Private Endpoint configuration
resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.resource_prefix}-ws-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = "${var.resource_prefix}-ws-psc"
    private_connection_resource_id = azurerm_machine_learning_workspace.this.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "private-dns-zone-group-ws"
    private_dns_zone_ids = [azurerm_private_dns_zone.ws_zone_api[count.index].id, azurerm_private_dns_zone.ws_zone_notebooks[count.index].id]
  }

  depends_on = [null_resource.compute_cluster]
}
