[[_TOC_]]

# Description

This snippet gets your Log Analytics Workspace Resource ID to be able to use it in a pipeline. You can set the pipeline variable name using the `OutputPipelineVariableName` parameter.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                              | Required                        | Example Value                               | Description                                                                                                                                                        |
| -------------------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| LogAnalyticsWorkspaceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup where your Log Analytics Workspace resides in.                                                                                       |
| LogAnalyticsWorkspaceName              | <input type="checkbox" checked> | `My-Shared-Law-$(Release.EnvironmentName)`  | The name of your Log Analytics Workspace.                                                                                                                          |
| OutputPipelineVariableName             | <input type="checkbox">         | `MyLogAnalyticsWorkspaceResourceId`         | The name of the pipeline variable. This defaults to `LogAnalyticsWorkspaceResourceId` and can be used inside the pipeline as `$(LogAnalyticsWorkspaceResourceId)`. |

# Output

You can set the pipeline variable name using the `OutputPipelineVariableName` parameter. For example: if the `OutputPipelineVariableName` is `MyLogAnalyticsWorkspaceResourceId`, you can use `$(MyLogAnalyticsWorkspaceResourceId)` in your pipeline after running this script in your pipeline.

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  name: GetLogAnalyticsWorkspaceResourceIdforPipeline
  displayName: "Get Log Analytics Workspace Resource Id"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Log-Analytics-Workspace/Get-Log-Analytics-Workspace-ResourceId-for-Pipeline.ps1"
    arguments: "-LogAnalyticsWorkspaceResourceGroupName '$(LogAnalyticsWorkspaceResourceGroupName)' -LogAnalyticsWorkspaceName '$(LogAnalyticsWorkspaceName)' -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../src/Log-Analytics-Workspace/Get-Log-Analytics-Workspace-ResourceId-for-Pipeline.ps1)

# Links

[Azure CLI - az monitor log-analytics workspace show](https://docs.microsoft.com/en-us/cli/azure/monitor/log-analytics/workspace?view=azure-cli-latest#az_monitor_log_analytics_workspace_show)
