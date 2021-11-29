# Logging and Tracing in Azure Machine Learning pipelines with Application Insights

## How to run this sample

### 1. Add dependencies

The following dependencies are required to use this package.

* Python 3.6+

```yaml
  - python-dotenv==0.19.*
  - dataclasses==0.*
  - opencensus==0.8.*
  - opencensus-context==0.1.*
  - opencensus-ext-azure==1.1.*
  - opencensus-ext-logging==0.1.*
  - opencensus-ext-httplib==0.7.*
```

### 2. Create and configure a Machine Learning Workspace

1. Create an Azure Machine Learning workspace.
1. Configure it with Azure Log Analytics using [this recipe](../../aml-log-analytics).

### 3. Configure environment variables to control logger behavior

> To define environment variables, use a `.env` file. If there is no `.env` file, actual environment variables will be used.

```bash
# name of an existing Azure Machine Learning workspace (required)
AML_WORKSPACE_NAME = 
# Azure Resource Group where the workspace is (required)
AML_RESOURCE_GROUP = 
# Azure Subscription where the workspace is (required)
SUBSCRIPTION_ID =
# Name of an Azure Machine Learning cluster. If it doesn't exist a Standard_DS3_v2 cluster will be created (required)
AML_TRAIN_COMPUTE =

# Console logger is enabled if set to 'true', default to 'true'
LOG_TO_CONSOLE = 'false'
# Azure ML logger is enabled when running as an experiment in Azure ML
# DEBUG, INFO, WARNING, ERROR, CRITICAL, default is WARNING
LOG_LEVEL = 'WARNING' 
# Probability 0.0 -> 1.0
LOG_SAMPLING_RATE = '1.0'
# Probability 0.0 -> 1.0
TRACE_SAMPLING_RATE = '1.0'
# Frequency in seconds to send metric to App Insights, default is 15
METRICS_EXPORT_INTERVAL = '15'
# Whether to log App Insights standard machine metrics, CPU, memory etc, default to 'false'
ENABLE_STANDARD_METRICS = 'true'
```

### 4. Run the sample

Run `python3 script-step/main.py` to deploy and submit a single-step Azure ML run that logs a couple of metrics and an error.
