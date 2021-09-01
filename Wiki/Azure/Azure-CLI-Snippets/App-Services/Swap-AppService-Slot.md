[[_TOC_]]

# Description

<font color="red">NOTE: This script is now legacy. Please use the standard task `Azure App Service Manage` instead of this task.</font>

This snippet will swap the Web Applications slots

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceResourceGroupName| `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your AppService reside in. |
| AppServiceName | `App-Service-name` | Name of the web application. |
| AppServiceSourceSlot | `'staging'` | Name of the source slot to swap from. |
| AppServiceTargetSlot | `'production'` | name of the destination slot to swap to. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Swap AppService Slot"
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Swap-AppService-Slot.ps1"
    arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceSourceSlot '$(AppServiceSourceSlot)' -AppServiceTargetSlot '$(AppServiceTargetSlot)'"
```

# Code

[Click here to download this script](../../../../src/App-Services/Swap-AppService-Slot.ps1)

# Links

- [Azure CLI - az webapp deployment slot swap](https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/slot?view=azure-cli-latest#az_webapp_deployment_slot_swap)
- [Azure app service staging slots](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots)
