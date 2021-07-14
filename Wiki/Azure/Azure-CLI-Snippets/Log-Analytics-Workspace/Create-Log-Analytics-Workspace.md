[[_TOC_]]

# Description

This snippet creates a log analytics workspace. It is recommended to leave the public interface switches off (only private access).

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                              | Required                        | Example Value                               | Description                                                                                                                                                      |
| -------------------------------------- | ------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| LogAnalyticsWorkspaceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your log analytics workspace to be created in                                                                             |
| LogAnalyticsWorkspaceName              | <input type="checkbox" checked> | `My-Shared-Law-$(Release.EnvironmentName)`  | The name you want to use for your log analytics-workspace.                                                                                                       |
| LogAnalyticsWorkspaceRetentionInDays   | <input type="checkbox">         | `30`                                        | OPTIONAL: The retention in days for the log analytics workspace. NOTE: The default value is 30 days.                                                             |
| PublicInterfaceIngestionEnabled        | <input type="checkbox">         | n.a.                                        | If you pass this switch (without value), public access for ingestion data will be enabled for this log analytics workspace (you still need to be authenticated). |
| PublicInterfaceQueryAccess             | <input type="checkbox">         | n.a.                                        | If you pass this switch (without value), public access for querying data will be enabled for this log analytics workspace (you still need to be authenticated).  |
| LogAnalyticsWorkspaceSolutionTypes     | <input type="checkbox">         | `'VMInsights', 'AlertManagement'`           | The solutions that can be added to the log analytics workspace can be added here.                                                                                |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
       - task: AzureCLI@2
           displayName: 'Create Log Analytics Workspace'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Log-Analytics-Workspace/Create-Log-Analytics-Workspace.ps1'
               arguments: "-LogAnalyticsWorkspaceResourceGroupName '$(LogAnalyticsWorkspaceResourceGroupName)' -LogAnalyticsWorkspaceName '$(LogAnalyticsWorkspaceName)' -LogAnalyticsWorkspaceRetentionInDays '$(LogAnalyticsWorkspaceRetentionInDays)' -PublicInterfaceIngestionEnabled -PublicInterfaceQueryAccess -ResourceTags $(ResourceTags) -LogAnalyticsWorkspaceSolutionTypes '$(LogAnalyticsWorkspaceSolutionTypes)'"
```

# Code

[Click here to download this script](../../../../src/Log-Analytics-Workspace/Create-Log-Analytics-Workspace.ps1)

# Links

[Azure CLI - az monitor log-analytics workspace create](https://docs.microsoft.com/en-us/cli/azure/monitor/log-analytics/workspace?view=azure-cli-latest#az_monitor_log_analytics_workspace_create)
