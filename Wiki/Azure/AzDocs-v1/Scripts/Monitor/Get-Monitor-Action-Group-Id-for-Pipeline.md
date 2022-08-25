[[_TOC_]]

# Description

This snippet will get the id for a monitor action group.

# Parameters

| Parameter                      | Required                        | Example Value               | Description                                                                            |
| ------------------------------ | ------------------------------- | --------------------------- | -------------------------------------------------------------------------------------- |
| MonitorActionGroupName         | <input type="checkbox" checked> | `monitor-action-group-name` | The name of the monitor action group.                                                  |
| MonitorActionResourceGroupName | <input type="checkbox" checked> | `resourcegroup-name`        | The resource group where the monitor action group exists.                              |
| OutputPipelineVariableName     | <input type="checkbox">         | `monitoractiongroupid`      | The variable name to be used inside the pipeline. Defaults to: `MonitorActionGroupId`. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Get Monitor Action Group Id"
  name: GetMonitorActionGroupId
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Get-Monitor-Action-Group-Id-for-Pipeline.ps1"
    arguments: "-MonitorActionGroupName '$(MonitorActionGroupName)' -MonitorActionResourceGroupName '$(MonitorActionResourceGroupName)' -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../src/Monitor/Get-Monitor-Action-Group-Id-for-Pipeline.ps1)

# Links

- [Azure CLI - az monitor action-group show](https://docs.microsoft.com/en-us/cli/azure/monitor/action-group?view=azure-cli-latest#az_monitor_action_group_show)
