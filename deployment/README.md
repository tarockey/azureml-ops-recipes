# Azure Machine Learning Deployment

This template deploys complete Azure Machine Learning enviornment via Terraform with very minimal inputs. It supports two kinds of following Azure Machine Learning deployments.

- Azure ML with private endpoints and VNet binding
- Azure ML without private endpoints and VNet binding.

With a single switch of terraform parameter you can choose which kind of AML architecture you want to deploy. The details of these deployments are discussed in the next sections.

## Architecture for Azure ML Resources With Private Endpoints and VNet Binding

![AML resources with Private Enpoints](images/aml_pe.png)

This includes deployment of the following resources:

- Azure Machine Learning Workspace with Private Link.
- Azure Storage Account with Private Link for Blob and File and VNET binding with Service Endpoints.
- Azure Key Vault with Private Link for Vault and VNET binding with Service Endpoints.
- Azure Container Registry (Private endpoints and VNET binding is not enabled as this feature needs to be requested from MSFT).
- Azure Application Insights.
- DSVM (Windows) for development and testing (in VNET and DSVMSubnet).
- DSVM is setup to auto shutdown at 18:00 PST to save on costs.
- Azure Bastion Host as an entry point to access the locked down enviornment via DSVM.
- One Virtual Network.
- AMLSubnet for AML Compute and AML resources such as Storage and KeyVault.
- DSVMSubnet for DSVM.
- AzureBastionSubnet for Bastion Host.
- Network Security group for DSVMSubnet which accepts incoming traffic from Bastion Host only.
- Network Security group for AzureVMSubnet which accepts incoming traffic from AzureCloud, GatewayManager and HTTPs.
- Managed AML Compute Cluster with scale up to 4 VMs (in VNET and AMLSubnet).
- Creates timestamp, create-by and environment Tags to all resources.

## Architecture for Azure ML Resources Without Private Endpoints and VNet Binding

![AML resources without Private Enpoints](images/aml_non_pe.png)

This includes deployment of the following resources:

- Azure Machine Learning Workspace.
- Azure Storage Account.
- Azure Key Vault.
- Azure Container Registry.
- Azure Application Insights.
- DSVM (Windows) for development and testing (in VNET and DSVMSubnet).
- DSVM is setup to auto shutdown at 18:00 PST to save on costs.
- Azure Bastion Host as an entry point to access the locked down enviornment via DSVM.
- One Virtual Network.
- AMLSubnet for AML Compute Cluster.
- DSVMSubnet for DSVM.
- AzureBastionSubnet for Bastion Host.
- Network Security group for DSVMSubnet which accepts incoming traffic from Bastion Host only.
- Network Security group for AzureVMSubnet which accepts incoming traffic from AzureCloud, GatewayManager and HTTPs.
- Managed AML Compute Cluster with scale up to 4 VMs (in VNET and AMLSubnet).
- Creates timestamp, create-by and environment Tags to all resources.

## Prerequisites

- [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Install Azure CLI ML extension by running `az extension add -n azure-cli-ml`
- [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)

## Run Deployment

Navigate to `deployment/terraform/aml`

- Run terraform init
- Run terraform plan
- Run terraform apply

> You will need to provide values for `project_code` and `env_code`
> Optional values:
>
> - `location`, default value is `West US 2`
> - `enable_private_endpoints`, default value is `true`.
> - `enable_log_analytics`, default value is `true`.
> - `log_analytics_workspace`, default value is empty
>
>   - `enable_log_analytics` must be `true`
>   - if provided, used to connect with Application Insights and Azure ML Workspace Diagnostics
>   - if not provided, a new Log Analytics Workspace will be created.
>

## Run Terraform Compliance Tests

[Terraform Compliance](https://terraform-compliance.com/) is a python based framework used to test against terraform execution plan
with the given scenarios (see folder `deployment/terraform/features`). You need Python 3.x to run it (see [installation docs](https://terraform-compliance.com/pages/installation/))

Execute the following steps to run the tests

```bash
cd deployment/terraform/aml
terraform init
terraform plan -out=plan.tfplan -var 'project_code=dp333' -var 'env_code=dev' -var 'location=West Europe' -var 'enable_private_endpoints=true'
terraform-compliance -p plan.tfplan -f ../features/
```

and review the output.

> For the current scenario implementation the location to be used has to be `West Europe`
