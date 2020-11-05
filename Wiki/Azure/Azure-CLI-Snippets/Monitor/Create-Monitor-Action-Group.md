[[_TOC_]]

# Description
This snippet will add an AppInsights Action Group. This is used to create a action group for sending alerts to (for example) OpsGenie.

NOTE: An action group belongs to a resourcegroup. It is not bound to a specific Application Insights resource.

# Parameters
| Parameter | Example Value | Description |
|--|--|--|
| actionGroupName | `OpsGenie $(Release.EnvironmentName) alerts` | The name of the actiongroup name. This is a function name, so a smart reference to the contents of the actiongroup is advised. |
| applicationResourceGroupName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group for the action group to be created in. Generally it is advised to use the application resource group (where also the AppInsights should live) |
| action | `@("email"; "emailtarget"; "my-receiver@domain.com")` | This value consists out of `@("<actionType>"; "<actionName>"; "<actionValue>")`. |


# Code
[Click here to download this script](../../../../src/Monitor/Create-Monitor-Action-Group.ps1)

# Links

- [Azure CLI - az extension add](https://docs.microsoft.com/en-us/cli/azure/extension?view=azure-cli-latest#az-extension-add)

- [Azure CLI - az monitor action group create](https://docs.microsoft.com/en-us/cli/azure/monitor/action-group?view=azure-cli-latest#az_monitor_action_group_create)