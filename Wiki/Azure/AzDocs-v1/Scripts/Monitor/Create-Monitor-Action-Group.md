[[_TOC_]]

# Description

This snippet will add an AppInsights Action Group. This is used to create a action group for sending alerts to (for example) OpsGenie.

NOTE: An action group belongs to a resourcegroup. It is not bound to a specific Application Insights resource.

# Parameters

| Parameter                           | Example Value                                         | Description                                                                                                                                                                  |
| ----------------------------------- | ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MonitorAlertActionGroupName         | `OpsGenie $(Release.EnvironmentName) alerts`          | The name of the actiongroup name. This is a function name, so a smart reference to the contents of the actiongroup is advised.                                               |
| MonitorAlertActionResourceGroupName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)`      | The name of the Resource Group for the action group to be created in. Generally it is advised to use the application resource group (where also the AppInsights should live) |
| AlertAction                         | `@("email"; "emailtarget"; "my-receiver@domain.com")` | This value consists out of `@("<actionType>"; "<actionName>"; "<actionValue>")`.                                                                                             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Monitor Action Group"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Create-Monitor-Action-Group.ps1"
    arguments: "-MonitorAlertActionGroupName '$(MonitorAlertActionGroupName)' -MonitorAlertActionResourceGroupName '$(MonitorAlertActionResourceGroupName)' -AlertAction '$(AlertAction)'"
```

# Code

[Click here to download this script](../../../../src/Monitor/Create-Monitor-Action-Group.ps1)

# Links

- [Azure CLI - az extension add](https://docs.microsoft.com/en-us/cli/azure/extension?view=azure-cli-latest#az-extension-add)

- [Azure CLI - az monitor action group create](https://docs.microsoft.com/en-us/cli/azure/monitor/action-group?view=azure-cli-latest#az_monitor_action_group_create)
