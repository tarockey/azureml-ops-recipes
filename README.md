# Azure Machine Learning Monitoring Recipes

This repository contains a work-in-progress set of recipes for monitoring Azure Machine Learning resources and pipelines.

Consolidating pipeline custom code telemetry with Azure ML infrastructure telemetry enables performing deeper analysis and monitoring of the performance of your machine learning workloads.

Azure Monitor and Log Analytics provide a powerful set of tools for monitoring and analyzing telemetry, with production-grade capabilities on analytical reporting and monitoring alerts.

A few examples of scenarios possible with Azure Monitor and Azure Machine Learning with these recipes applied:

1. Alerts on model training failures with insights on respective infrastructure events and/or pipeline code exceptions.
1. Monitoring ML model metrics with alerts on various events, such as model performance degradation, successful model training runs, etc.
1. Azure Monitor Workbooks or Power BI reports on CPU and GPU compute utilization across ML experiments and runs for compute optimization and cost analysis.

The following recipes are currently available:

1. **Configuring Azure Machine Learning Workspace with Azure Log Analytics**. This recipe is required for sending all Azure Machine Learning telemetry to Azure Log Analytics workspace.
1. **Application Insights for Azure Machine Learning Pipelines**. This recipe is a Python package for Consolidating Azure ML Pipeline telemetry in Azure Monitor with Application Insights. It provides a single class for logging traces and metrics to Application Insights and existing Azure ML logging mechanisms (which can also be accessed using MLFlow APIs).
1. **Log Analytics Samples**. This recipe provides a few examples of how to use consolidated Azure Machine Learning telemetry with Azure Log Analytics.

## Configuring Azure Machine Learning Workspace with Azure Log Analytics

* [aml-log-analytics](aml-log-analytics) - Terraform scripts for configuring an existing Azure Machine Learning workspace with Azure Log Analytics for monitoring and analysis.

The deployment scripts automate the following steps:

1. Create a new Azure Log Analytics Workspace (optional).
1. Configuring Application Insights instance attached to Azure ML Workspace for sending data to Log Analytics by making it a [Workspace-based Application Insights resource](https://docs.microsoft.com/en-us/azure/azure-monitor/app/convert-classic-resource).
1. Configuring Azure Machine Learning workspace with [sending events and metrics to Log Analytics](https://docs.microsoft.com/en-us/azure/machine-learning/monitor-azure-machine-learning#collection-and-routing).

Consolidating pipeline custom code telemetry with Azure ML infrastructure telemetry enables performing deeper analysis and monitoring of the performance of your machine learning workloads.

## Application Insights for Azure Machine Learning Pipelines

* [azureml-run-telemetry](azureml-run-telemetry) - A Python package for Consolidating Azure ML Pipeline telemetry in Azure Monitor with Application Insights.

> Includes [samples](azureml-run-telemetry/samples).

This package introduces [Observability](azureml-run-telemetry/azureml_appinsights_logger/observability.py#L53) class that consolidates the telemetry from Azure ML Pipelines in Azure Monitor with Application Insights, along with built-in Azure ML logging capabilities.

## Log Analytics Samples

* [log-anaytics-samples](log-anaytics-examples) - Examples of monitoring and analyzing Azure Machine Learning pipelines with Azure Log Analytics.

> These samples require Azure ML workspace to be configured with Azure Log Analytics, and assume that you run [samples from azureml-run-telemetry package](azureml-run-telemetry/samples).

1. [log-anaytics-samples/log-analytics-jupyter](log-anaytics-examples/log-analytics-jupyter) - Jupyter Notebook sample for monitoring and analyzing Azure Machine Learning pipelines with Azure Log Analytics.
1. [log-anaytics-samples/log-analytics-queries](log-anaytics-examples/log-analytics-queries) - Azure Resource Manager template of a Log Analytics workbook for monitoring and analyzing Azure Machine Learning pipelines.