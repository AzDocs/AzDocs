[[_TOC_]]

# Description

This snippet will add a log alert rule with type metric. This can be used to create an alert rule and attach an action group to this alert rule.

# Parameters

## Default parameters

| Parameter                                   | Required                        | Example Value                                   | Description                                                                                                                    |
| ------------------------------------------- | ------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| ResourceToMonitorName                       | <input type="checkbox" checked> | `AppService-name`                               | The name of the resource to monitor                                                                                            |
| ResourceToMonitorResourceGroupName          | <input type="checkbox" checked> | `AppService-resourcegroup`                      | The resource group of the resource to monitor                                                                                  |
| MetricAlertRuleName                         | <input type="checkbox" checked> | `alert-rule-name`                               | The alert rule name                                                                                                            |
| MetricAlertRuleResourceGroupName            | <input type="checkbox" checked> | `Monitoring-release-$(Release.EnvironmentName)` | The name of the Resource Group the alert rule to be created in.                                                                |
| MetricAlertRuleDescription                  | <input type="checkbox" checked> | `alert rule description`                        | The description of the alert rule.                                                                                             |
| MetricAlertRuleWindowSizeInMinutes          | <input type="checkbox" checked> | `5`                                             | Time over which to aggregate metrics in minutes.                                                                               |
| MetricAlertRuleEvaluationFrequencyInMinutes | <input type="checkbox" checked> | `5`                                             | Frequency with which to evaluate the rule in  minutes.                                                                         |
| MetricAlertRuleSeverity                     | <input type="checkbox">         | `3`                                             | Severity of the alert, can be 0 (critical), 1 (Error), 2 (Warning), 3 (Informational) or 4 (Verbose). The default is 3.        |
| MonitorAlertActionGroupName                 | <input type="checkbox" checked> | `action-group-name`                             | The name of the actiongroup name. This is a function name, so a smart reference to the contents of the actiongroup is advised. |
| MonitorAlertActionResourceGroupName         | <input type="checkbox" checked> | `action-group-resourcegroup`                    | The name of the Resource Group for the action group to be created in.                                                          |

## Additional Condition parameters

| Parameter                                  | Required                                           | Example Value | Description                                                                                                                                                                            |
| ------------------------------------------ | -------------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MetricAlertRuleConditionSignalName         | <input type="checkbox" checked>                    | `Http500`     | The name of the metric to be used, to receive a list of possible values use `az monitor metrics list-definitions --resource $resourceId`.                                              |
| MetricAlertRuleConditionAggregation        | <input type="checkbox" checked>                    | `Average`     | The time aggregation, can be one of the following: "Average", "Count", "Maximum", "Minimum", "Total"                                                                                   |
| MetricAlertRuleConditionOperation          | <input type="checkbox" checked>                    | `GreaterThan` | The threshold operator for the trigger. Can be one of the following: "GreaterThan", "LessThan" or "Equal".                                                                             |
| MetricAlertRuleConditionType               | <input type="checkbox" checked>                    | `static`      | The threshold value type for the trigger. Can be one of the following: "static", "dynamic"                                                                                             |
| MetricAlertRuleConditionDynamicSensitivity | <input type="checkbox">                            | `Medium`      | When MetricAlertRuleConditionType is set to "dynamic", this is used to determine the threshold sensitivity. Can be one of the following: "High", "Medium", "Low". Default is "Medium". |
| MetricAlertRuleConditionStaticThreshold    | only when MetricAlertRuleConditionType is 'static' | `10`          | When MetricAlertRuleConditionType is set to "static" this is the threshold value. Default is 0                                                                                         |

## Additional Dimension parameters, only required when you want to use a dimension in the condition. 

| Parameter                                 | Required                        | Example Value  | Description                                                                                           |
| ----------------------------------------- | ------------------------------- | -------------- | ----------------------------------------------------------------------------------------------------- |
| MetricAlertRuleConditionDimensionName     | <input type="checkbox" checked> | `propertyname` | The name of the dimension                                                                             |
| MetricAlertRuleConditionDimensionValue    | <input type="checkbox" checked> | `SomeValue`    | The values to apply on the operation                                                                  |
| MetricAlertRuleConditionDimensionOperator | <input type="checkbox">         | `Exclude`      | The dimension operator, must be one of the following: "Include", "Exclude". The default is "Include". |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Metric Alert Rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Create-Metric-Alert-Rule.ps1"
    arguments: "-ResourceToMonitorName '$(ResourceToMonitorName)' -ResourceToMonitorResourceGroupName '$(ResourceToMonitorResourceGroupName)' -MetricAlertRuleName '$(MetricAlertRuleName)' -MetricAlertRuleResourceGroupName '$(MetricAlertRuleResourceGroupName)' -MetricAlertRuleDescription '$(MetricAlertRuleDescription)' -MetricAlertRuleWindowSizeInMinutes '$(MetricAlertRuleWindowSizeInMinutes)' -MetricAlertRuleEvaluationFrequencyInMinutes '$(MetricAlertRuleEvaluationFrequencyInMinutes)' -MetricAlertRuleSeverity '$(MetricAlertRuleSeverity)' -MonitorAlertActionGroupName '$(MonitorAlertActionGroupName)' -MonitorAlertActionResourceGroupName '$(MonitorAlertActionResourceGroupName)' -MetricAlertRuleConditionSignalName '$(MetricAlertRuleConditionSignalName)' -MetricAlertRuleConditionAggregation '$(MetricAlertRuleConditionAggregation)' -MetricAlertRuleConditionOperation '$(MetricAlertRuleConditionOperation)' -MetricAlertRuleConditionType '$(MetricAlertRuleConditionType)' -MetricAlertRuleConditionDynamicSensitivity '$(MetricAlertRuleConditionDynamicSensitivity)' -MetricAlertRuleConditionStaticThreshold '$(MetricAlertRuleConditionStaticThreshold)' -MetricAlertRuleConditionDimensionName '$(MetricAlertRuleConditionDimensionName)' -MetricAlertRuleConditionDimensionValue '$(MetricAlertRuleConditionDimensionValue)' -MetricAlertRuleConditionDimensionOperator '$(MetricAlertRuleConditionDimensionOperator)'"
```

# Code

[Click here to download this script](../../../../src/Monitor/Create-Metric-Alert-Rule.ps1)

# Links

- [Azure - create log alerts](https://docs.microsoft.com/nl-nl/azure/azure-monitor/alerts/alerts-log)
