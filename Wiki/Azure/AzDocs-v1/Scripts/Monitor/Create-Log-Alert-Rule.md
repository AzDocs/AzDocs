[[_TOC_]]

# Description

This snippet will add a log alert rule with type log search. This can be used to create an alert rule and attach an action group to this alert rule.

# Parameters

## Default parameters

| Parameter                                        | Required                        | Example Value                                                                                                               | Description                                                                                                                           |
| ------------------------------------------------ | ------------------------------- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| MonitorAlertActionGroupName                      | <input type="checkbox" checked> | `OpsGenie $(Release.EnvironmentName) alerts`                                                                                | The name of the actiongroup name. This is a function name, so a smart reference to the contents of the actiongroup is advised.        |
| MonitorAlertActionGroupResourceGroupName         | <input type="checkbox" checked> | `Monitoring-release-$(Release.EnvironmentName)`                                                                             | The name of the Resource Group for the action group to be created in.                                                                 |
| MonitorAlertQuery                                | <input type="checkbox" checked> | `Heartbeat \| where Computer contains '$(Containsvalue)' \| where TimeGenerated > ago(1h) \| summarize count() by Computer` | The query that will be used for your log alert.                                                                                       |
| LogAnalyticsWorkspaceResourceId                  | <input type="checkbox" checked> | n.a.                                                                                                                        | The resource id of the log analytics workspace that is used to run your query.                                                        |
| MonitorAlertFrequencyInMinutes                   | <input type="checkbox" checked> | 60                                                                                                                          | The time span over which to execute the MonitorAlertQuery in minutes.                                                                 |
| MonitorAlertTimeWindowInMinutes                  | <input type="checkbox" checked> | 5                                                                                                                           | The frequency on how often the MonitorAlertQuery should be run in minutes.                                                            |
| MonitorAlertTriggerThresholdOperator             | <input type="checkbox" checked> | `GreaterThan`                                                                                                               | The trigger threshold operator can be set for the alert. The value can be one of the following: "GreaterThan", "LessThan" or "Equal". |
| MonitorAlertTriggerThreshold                     | <input type="checkbox" checked> | `60`                                                                                                                        | The threshold for the trigger of the alert can be set.                                                                                |
| MonitorAlertingActionSeverity                    | <input type="checkbox" checked> | `3`                                                                                                                         | The severity for the alert can be set.                                                                                                |
| MonitorAlertingActionSuppressThrottlingInMinutes | <input type="checkbox" checked> | `10`                                                                                                                        | With this value you can suppress the same alerts for a certain amount in minutes.                                                     |
| MonitorAlertRuleResourceGroupName                | <input type="checkbox" checked> | `Monitoring-release-$(Release.EnvironmentName)`                                                                             | The name of the Resource Group the alert rule to be created in.                                                                       |
| MonitorAlertRuleResourceGroupLocation            | <input type="checkbox" checked> | `westeurope`                                                                                                                | The location where the resource group exists.                                                                                         |
| MonitorAlertRuleEnabled                          | <input type="checkbox">         | `true`                                                                                                                      | If the alert rule is enabled upon creation. Has a default value of true.                                                              |
| MonitorAlertRuleName                             | <input type="checkbox" checked> | `alert-rule-name`                                                                                                           | The name of the alert rule.                                                                                                           |
| MonitorAlertRuleDescription                      | <input type="checkbox" checked> | `alert-rule-description`                                                                                                    | The description of the alert rule.                                                                                                    |
| MonitorAlertCustomActionEmailSubject             | <input type="checkbox" >        | `email subject line`                                                                                                        | The subject line of the email can be made custom with this property.                                                                  |

## Additional Metric parameters

| Parameter                                  | Required                        | Example Value | Description                                                                                                                                                                                |
| ------------------------------------------ | ------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| MonitorAlertMetricTrigger                  | <input type="checkbox" checked> | n.a.          | This switch can be set to add metric triggers to the alert rule.                                                                                                                           |
| MonitorAlertMetricTriggerThresholdOperator | <input type="checkbox" checked> | `GreaterThan` | When the switch MonitorAlertMetricTrigger is set, the threshold operator for the trigger has to be filled. These values can be one of the following: "GreaterThan", "LessThan" or "Equal". |
| MonitorAlertMetricTriggerThreshold         | <input type="checkbox" checked> | `5`           | When the switch MonitorAlertMetricTrigger is set, the threshold can be set for the metric trigger.                                                                                         |
| MonitorAlertMetricTriggerType              | <input type="checkbox" checked> | `Consecutive` | When the switch MonitorAlertMetricTrigger is set, the trigger type has to be set for the metric trigger. This can consist of the following two types: "Consecutive" or "Total".            |
| MonitorAlertMetricColumn                   | <input type="checkbox" checked> | `Computer`    | When the switch MonitorAlertMetricTrigger is set, the metric column can be set.                                                                                                            |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzurePowerShell@5
  displayName: "Create Log Alert Rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    ScriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Create-Log-Alert-Rule.ps1"
    ScriptArguments: "-MonitorAlertActionGroupName '$(MonitorAlertActionGroupName)' -MonitorAlertActionGroupResourceGroupName '$(MonitorAlertActionGroupResourceGroupName)' -MonitorAlertQuery '$(MonitorAlertQuery)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -MonitorAlertFrequencyInMinutes '$(MonitorAlertFrequencyInMinutes)' -MonitorAlertTimeWindowInMinutes '$(MonitorAlertTimeWindowInMinutes)' -MonitorAlertMetricTriggerThresholdOperator '$(MonitorAlertMetricTriggerThresholdOperator)' -MonitorAlertMetricTriggerThreshold '$(MonitorAlertMetricTriggerThreshold)' -MonitorAlertMetricTriggerType '$(MonitorAlertMetricTriggerType)' -MonitorAlertMetricColumn '$(MonitorAlertMetricColumn)' -MonitorAlertTriggerThresholdOperator '$(MonitorAlertTriggerThresholdOperator)' -MonitorAlertTriggerThreshold '$(MonitorAlertTriggerThreshold)' -MonitorAlertingActionSeverity '$(MonitorAlertingActionSeverity)' -MonitorAlertingActionSuppressThrottlingInMinutes '$(MonitorAlertingActionSuppressThrottlingInMinutes)' -MonitorAlertRuleResourceGroupName '$(MonitorAlertRuleResourceGroupName)' -MonitorAlertRuleResourceGroupLocation '$(MonitorAlertRuleResourceGroupLocation)' -MonitorAlertRuleEnabled $(MonitorAlertRuleEnabled) -MonitorAlertRuleName '$(MonitorAlertRuleName)' -MonitorAlertRuleDescription '$(MonitorAlertRuleDescription)' -MonitorAlertCustomActionEmailSubject '$(MonitorAlertCustomActionEmailSubject)'"
    FailOnStandardError: true
    azurePowerShellVersion: LatestVersion
    pwsh: true
```

# Code

[Click here to download this script](../../../../src/Monitor/Create-Log-Alert-Rule.ps1)

# Links

- [Azure - create log alerts](https://docs.microsoft.com/nl-nl/azure/azure-monitor/alerts/alerts-log)
