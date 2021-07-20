[[_TOC_]]

# Description

This snippet will add vnet-integration to an existing appservice.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this. |
| AppServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the appservice resides in|
| VnetName | `myVirtualNetwork` | The name of the virutal network to connect to. |
| AppServiceVnetIntegrationVnetName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET where the vnet integration should take place. |
| AppServiceVnetIntegrationSubnetName | `app-subnet-4` | The name of the subnet to place the vnet-integration in. Note: Adding an appservice vnetintegration to a subnet will delegate that entire subnet to the appservice. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |
| AppServiceSlotName | `staging` | OPTIONAL By default the production slot is used, use this variable to use a different slot. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Add VNet integration to AppService'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Services/Add-VNet-integration-to-AppService.ps1'
               arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceVnetIntegrationVnetName '$(AppServiceVnetIntegrationVnetName)' -AppServiceVnetIntegrationSubnetName '$(AppServiceVnetIntegrationSubnetName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/App-Services/Add-VNet-integration-to-AppService.ps1)

# Links

- [Azure CLI - az-webapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-list)
- [Azure CLI - az-webapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-add)
- [Azure CLI - az-webapp-restart](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az-webapp-restart)
