[[_TOC_]]

# Description

This snippet will create a SignalR service.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                       | Required                        | Example Value                                | Description                                                                                                                                       |
| ------------------------------- | ------------------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| SignalrName                     | <input type="checkbox" checked> | `mysignalr`                                  | The name of the SignalR service.                                                                                                                  |
| SignalrResourceGroup            | <input type="checkbox" checked> | `resourcegroup`                              | The name of the resourcegroup where your SignalR resourcegroup resides in.                                                                        |
| SignalrSku                      | <input type="checkbox" checked> | `Standard`                                   | This is the sku you can choose for your ServiceBus Namespace. You have a choice between 'Standard_S1', 'Premium_P1'.                              |
| SignalrServiceMode              | <input type="checkbox">         | `Classic`, `Default`, `Serverless`           | The mode your SignalR service will be running on. You can choose from 'Classic','Default'or 'Serverless'.                                         |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | `loganalyticsworkspaceresourceid`            | The resource id of your log analytics workspace.                                                                                                  |
| SignalrAllowedOrigins           | <input type="checkbox">         | `https://{domain}.com https://{domain2}.com` | A list of allowed origins, space separated. By default allows all (`*`).                                                                          |
| SignalrUnitCount                | <input type="checkbox">         | `1`                                          | The unit count of your SignalR service. Defaults to 1.                                                                                            |
| DiagnosticSettingsLogs          | <input type="checkbox">         | `@('Requests';'MongoRequests';)`             | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.       |
| DiagnosticSettingsMetrics       | <input type="checkbox">         | `@('Requests';'MongoRequests';)`             | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled. |
| DiagnosticSettingsDisabled      | <input type="checkbox">         | n.a.                                         | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                 |


# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create SignalR Service"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/SignalR/Create-SignalR-Service.ps1"
    arguments: "-SignalrName '$(SignalrName)' -SignalrResourceGroup '$(SignalrResourceGroup)' -SignalrSku '$(SignalrSku)' -SignalrServiceMode '$(SignalrServiceMode)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -SignalrAllowedOrigins '$(SignalrAllowedOrigins)' -SignalrUnitCount '$(SignalrUnitCount)' -ResourceTags $(Resource.Tags) -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/SignalR/Create-SignalR-Service.ps1)

# Links

[Azure CLI - az signalr create](https://docs.microsoft.com/en-us/cli/azure/signalr?view=azure-cli-latest#az-signalr-create)
