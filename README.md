# Azure Machine Learning Monitoring Recipes

This repository contains a work-in-progress set of recipes for monitoring Azure Machine Learning resources and pipelines.

## Configuring Azure Machine Learning Workspace with Azure Log Analytics

* [aml-log-analytics](aml-log-analytics) - Terraform scripts for configuring an existing Azure Machine Learning workspace with Azure Log Analytics for monitoring.

## Application Insights for Azure Machine Learning Pipelines

* [azureml-run-telemetry](azureml-run-telemetry) - A Python package for Consolidating Azure ML Pipeline telemetry in Azure Monitor with Application Insights.

> Includes [samples](azureml-run-telemetry/samples).

## Log Analytics Samples

* [log-anaytics-samples](log-anaytics-examples) - Examples of monitoring and analyzing Azure Machine Learning pipelines with Azure Log Analytics.

> These samples require Azure ML workspace to be configured with Azure Log Analytics, and assume that you run [samples from azureml-run-telemetry package](azureml-run-telemetry/samples).

1. [log-anaytics-samples/log-analytics-jupyter](log-anaytics-examples/log-analytics-jupyter) - Jupyter Notebook sample for monitoring and analyzing Azure Machine Learning pipelines with Azure Log Analytics.
1. [log-anaytics-samples/log-analytics-queries](log-anaytics-examples/log-analytics-queries) - Azure Resource Manager template of a Log Analytics workbook for monitoring and analyzing Azure Machine Learning pipelines.