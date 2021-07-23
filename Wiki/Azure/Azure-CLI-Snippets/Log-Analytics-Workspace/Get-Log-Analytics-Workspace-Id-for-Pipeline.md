[[_TOC_]]

# Description

This snippet gets your Log Analytics Workspace id to be able to use it in a pipeline. It will output the resource id in the variable `$(LogAnalyticsWorkspaceResourceId)`.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                              | Required                        | Example Value                               | Description                                                                          |
| -------------------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------ |
| LogAnalyticsWorkspaceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your log analytics workspace to be created in |
| LogAnalyticsWorkspaceName              | <input type="checkbox" checked> | `My-Shared-Law-$(Release.EnvironmentName)`  | The name you want to use for your log analytics-workspace.                           |

# Output

The variable this script will output is the `$(LogAnalyticsWorkspaceResourceId)`.

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
       - task: AzureCLI@2
              displayName: "Get Log Analytics Workspace Id"
              condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
              inputs:
                azureSubscription: "${{ parameters.SubscriptionName }}"
                scriptType: pscore
                scriptPath: "$(Pipeline.Workspace)/AzDocs/Log-Analytics-Workspace/Get-Log-Analytics-Workspace-Id-for-Pipeline.ps1"
                arguments: "-LogAnalyticsWorkspaceResourceGroupName '$(LogAnalyticsWorkspaceResourceGroupName)' -LogAnalyticsWorkspaceName '$(LogAnalyticsWorkspaceName)'"
```

# Code

[Click here to download this script](../../../../src/Log-Analytics-Workspace/Get-Log-Analytics-Workspace-Id-for-Pipeline.ps1)

# Links

[Azure CLI - az monitor log-analytics workspace show](https://docs.microsoft.com/en-us/cli/azure/monitor/log-analytics/workspace?view=azure-cli-latest#az_monitor_log_analytics_workspace_show)
