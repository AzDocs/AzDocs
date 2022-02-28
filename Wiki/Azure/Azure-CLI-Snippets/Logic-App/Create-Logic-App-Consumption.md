[[_TOC_]]

# Description

This snippet will create a Logic App (Consumption). This means that this Logic App is NOT created within a specific Logic App AppService Plan.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
| ----------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LogicAppName | <input type="checkbox" checked> | `azuretestlogicapp$(Release.EnvironmentName)` | The name of the logic app. It's recommended to stick to lowercase alphanumeric characters for this. |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace the Logic App is using for writing its diagnostics settings) |
| LogicAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your desired Logic App will reside in |
| LogicAppStorageAccountName | <input type="checkbox" checked> | `azuretestlogicapp$(Release.EnvironmentName)storage` | The name of the (pre-existing) storage account which will be the backend storage for this logic app |
| DiagnosticSettingsLogs | <input type="checkbox"> | `@('Requests';'MongoRequests';)` | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled. |
| DiagnosticSettingsMetrics | <input type="checkbox"> | `@('Requests';'MongoRequests';)` | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled. |
| DiagnosticSettingsDisabled | <input type="checkbox"> | n.a. | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`). |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Logic App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Logic-App/Create-Logic-App-Consumption.ps1"
    arguments: >
      -LogicAppResourceGroupName $(LogicAppResourceGroupName)
      -LogicAppName $(LogicAppName)
      -LogicAppDefinitionPath $(LogicAppDefinitionPath)
      -LogicAppLocation $(LogicAppLocation)
      -LogAnalyticsWorkspaceResourceId $(LogAnalyticsWorkspaceResourceId)
      -DiagnosticSettingsLogs $(DiagnosticSettingsLogs)
      -DiagnosticSettingsMetrics $(DiagnosticSettingsMetrics)
      -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)
```

# Code

## Create Logic App

The snippet to create a Logic App.

[Click here to download this script](../../../../src/Logic-App/Create-Logic-App.ps1)

# Links

- [Azure CLI - az-logic-workflow-create](https://docs.microsoft.com/en-us/cli/azure/logic/workflow?view=azure-cli-latest#az-logic-workflow-create)
- [Create Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/diagnostic-settings)
- [Az Monitor Diagnostics settings](https://docs.microsoft.com/en-us/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az-monitor-diagnostic-settings-update)
- [Enable Diagnostics Logging](https://docs.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs)
- [Template settings for Diagnostics settings](https://docs.microsoft.com/en-us/azure/azure-monitor/samples/resource-manager-diagnostic-settings)
- [Diagnostics settings](http://techgenix.com/azure-diagnostic-settings/)
