provider "azurerm" {
  version = "=2.85"
  features {
  }
}

data "azurerm_client_config" "this" {
}

locals {
  existing_aml_map = regex(
        "(?i)^/Subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/(?P<provider>[^/]+)/.+/(?P<resource_name>.+)$",
        var.azureml_workspace)
  existing_la_map = var.existing_log_analytics_workspace != "" ? regex(
            "(?i)^/Subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/(?P<provider>[^/]+)/.+/(?P<resource_name>.+)$",
            var.existing_log_analytics_workspace) : null
}

# existing Azure Machine Learning Workspace
data "azurerm_machine_learning_workspace" "aml_workspace" {
  name                      = local.existing_aml_map.resource_name
  resource_group_name       = local.existing_aml_map.resource_group
}

data "external" "aml_workspace_all" {
  program = ["az", "ml", "workspace", "show",
    "--only-show-errors", "--output", "json",
    "--name", local.existing_aml_map.resource_name,
    "--resource-group", local.existing_aml_map.resource_group]

  depends_on = [
    data.azurerm_machine_learning_workspace.aml_workspace
  ]
}

locals {
  aml_json = jsondecode(data.external.aml_workspace_all.result)
  app_insights_map = regex(
        "(?i)^/Subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/(?P<provider>[^/]+)/.+/(?P<resource_name>.+)$",
        local.aml_json.application_insights)
  key_vault = local.aml_json.key_vault
  location = local.aml_json.location
}

# new Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "new_la_workspace" {
  count               = var.existing_log_analytics_workspace != "" ? 0 : 1
  name                = "${data.azurerm_machine_learning_workspace.aml_workspace.name}-log-analytics"
  location            = local.location
  resource_group_name = data.azurerm_machine_learning_workspace.aml_workspace.resource_group_name
  tags                = var.log_analytics_tags
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_in_days
}

locals {
  la_workspace = var.existing_log_analytics_workspace != "" ? var.existing_log_analytics_workspace : azurerm_log_analytics_workspace.new_la_workspace[0].id
}

# make sure Application Insights resource is configured with Log Analytics workspace
data "azurerm_application_insights" "app_insights" {
  name                = local.app_insights_map.resource_name
  resource_group_name = local.app_insights_map.resource_group
}

resource "null_resource" "upgrade_app_insights" {
  provisioner "local-exec" {
    command = "az monitor app-insights component update --app ${local.app_insights_map.resource_name} --resource-group ${local.app_insights_map.resource_group} --workspace ${local.la_workspace}"
  }
}

# Create applicationinsights-connection-string secret in the Azure ML workspace's Key Vault
resource "azurerm_key_vault_secret" this {
  name         = "applicationinsights-connection-string"
  value        = data.azurerm_application_insights.app_insights.instrumentation_key
  key_vault_id = local.key_vault
}

resource "null_resource" "diag_settings" {
  provisioner "local-exec" {
    command = "az monitor diagnostic-settings create -n SendAllToLogAnalytics --resource ${var.azureml_workspace} --workspace ${local.la_workspace} --logs '[{\"category\":\"AmlComputeClusterEvent\",\"enabled\":true},{\"category\":\"AmlComputeClusterNodeEvent\",\"enabled\":true},{\"category\":\"AmlComputeJobEvent\",\"enabled\":true},{\"category\":\"AmlComputeCpuGpuUtilization\",\"enabled\":true},{\"category\":\"AmlRunStatusChangedEvent\",\"enabled\":true},{\"category\":\"ModelsChangeEvent\",\"enabled\":true},{\"category\":\"ModelsReadEvent\",\"enabled\":true},{\"category\":\"ModelsActionEvent\",\"enabled\":true},{\"category\":\"DeploymentReadEvent\",\"enabled\":true},{\"category\":\"DeploymentEventACI\",\"enabled\":true},{\"category\":\"DeploymentEventAKS\",\"enabled\":true},{\"category\":\"InferencingOperationAKS\",\"enabled\":true},{\"category\":\"InferencingOperationACI\",\"enabled\":true},{\"category\":\"EnvironmentChangeEvent\",\"enabled\":true},{\"category\":\"EnvironmentReadEvent\",\"enabled\":true},{\"category\":\"DataLabelChangeEvent\",\"enabled\":true},{\"category\":\"DataLabelReadEvent\",\"enabled\":true},{\"category\":\"ComputeInstanceEvent\",\"enabled\":true},{\"category\":\"DataStoreChangeEvent\",\"enabled\":true},{\"category\":\"DataStoreReadEvent\",\"enabled\":true},{\"category\":\"DataSetChangeEvent\",\"enabled\":true},{\"category\":\"DataSetReadEvent\",\"enabled\":true},{\"category\":\"PipelineChangeEvent\",\"enabled\":true},{\"category\":\"PipelineReadEvent\",\"enabled\":true},{\"category\":\"RunEvent\",\"enabled\":true},{\"category\":\"RunReadEvent\",\"enabled\":true}]' --metrics '[{\"category\":\"AllMetrics\",\"Enabled\":true}]'"
  }
}