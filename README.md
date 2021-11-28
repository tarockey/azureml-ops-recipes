# Azure Machine Learning Monitoring Recipes

## Requirements

* Deployment scripts must be executed on Linux, macOS or Windows Subsystem for Linux
* [Terraform 1.0.11+](https://www.terraform.io/downloads.html)
* [Azure CLI 2.30+](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Azure Machine Learning CLI v2](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-configure-cli)

## Deployment

### 1. Initialize Terraform Module

```bash
cd terraform/aml_log_anaytics
terraform init
```

### 2. Create a Terraform Plan

**Option 1**: Creating a new Azure Log Analytics Workspace

```bash
terraform plan -var 'azureml_workspace=<Azure Resource ID of an existing Azure ML workspace' -out=plan.tfplan
```

When creating a new Log Analytics Workspace, you can provide the following optional variables (using `-var` parameters):

* `log_analytics_sku` - Azure Log Analytics SKU, default value is `PerGB2018`
* `log_analytics_retention_in_days` - Log Analytics Data Retention period is `90`
* `log_analytics_tags` - tags to assign to Log Analytics Workspace, default is empty

**Option 2**: Using an existing Azure Log Analytics Workspace

```bash
terraform plan \
    -var 'azureml_workspace=<Azure Resource ID of an existing Azure ML workspace>' \
    -var 'existing_log_analytics_workspace=<Azure Resource ID of an existing Azure ML workspace>'\
    -out=plan.tfplan
```

### 3. Execute Terraform Plan

```bash
terraform apply -auto-approve plan.tfplan
```

### Example

```bash
cd terraform/aml_log_anaytics
terraform init
terraform plan -var 'azureml_workspace="/subscriptions/af10f960-61a9-4c1c-a9a9-2abb2ea1629b/resourceGroups/aml-observability-rg/providers/Microsoft.MachineLearningServices/workspaces/aml-observability"' -out=plan.tfplan
terraform apply -auto-approve plan.tfplan
```
