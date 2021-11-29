# Examples of Azure Log Analytics queries

## Experiments with successful Runs that logged errors

```sql
AppTraces
| where Properties.level == "ERROR"
| extend ExperimentName=tostring(Properties.experiment_name), CorrelationId=tostring(Properties.correlation_id)
| join (AmlRunStatusChangedEvent 
        | where Status == "Completed"
        | project RunId, RunStatus=Status, WorkspaceName) on $left.CorrelationId==$right.RunId
| summarize Count=count() by ExperimentName, RunId
| render barchart
```

## Failed Runs per Experiment

```sql
AmlComputeJobEvent
| where OperationName == "JobFailed"
| summarize Count=count() by ExperimentName, JobName
| render barchart
```
