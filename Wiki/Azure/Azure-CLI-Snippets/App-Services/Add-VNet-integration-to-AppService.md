- [Description](#description)
- [Parameters](#parameters)
- [YAML](#yaml)
- [Code](#code)
- [Links](#links)

# Description

This snippet will add vnet-integration to an existing appservice.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter                           | Required                        | Example Value                               | Description                                                                                                                                                                                                                                                                                            |
| ----------------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| AppServiceName                      | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The name of the webapp. It's recommended to stick to alphanumeric & hyphens for this.                                                                                                                                                                                                                  |
| AppServiceResourceGroupName         | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the appservice resides in.                                                                                                                                                                                                                                                     |
| VnetName                            | <input type="checkbox" checked> | `myVirtualNetwork`                          | The name of the virutal network to connect. to.                                                                                                                                                                                                                                                        |
| AppServiceVnetIntegrationVnetName   | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`        | The name of the VNET where the vnet integration should take. place.                                                                                                                                                                                                                                    |
| AppServiceVnetIntegrationSubnetName | <input type="checkbox" checked> | `app-subnet-4`                              | The name of the subnet to place the vnet-integration in. Note: Adding an appservice vnetintegration to a subnet will delegate that entire subnet to the appservice. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |
| AppServiceSlotName                  | <input type="checkbox" checked> | `staging`                                   | OPTIONAL By default the production slot is used, use this variable to use a different. slot.                                                                                                                                                                                                           |
| ApplyToAllSlots                     | <input type="checkbox">         | `$true`/`$false`                            | Applies the current script to all slots revolving this. resource                                                                                                                                                                                                                                       |
| RouteAllTrafficThroughVnet               | <input type="checkbox" checked> | `$true`/`$false`                            | If true, all the traffic is routed through the vnet. If false only [Private Address Space](https://datatracker.ietf.org/doc/html/rfc1918#section-3) is routed through the vnet.                                                                                                                        |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add VNet integration to AppService"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Add-VNet-integration-to-AppService.ps1"
    arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceVnetIntegrationVnetName '$(AppServiceVnetIntegrationVnetName)' -AppServiceVnetIntegrationSubnetName '$(AppServiceVnetIntegrationSubnetName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots) -RouteAllTrafficThroughVnet $true"
```

# Code

[Click here to download this script](../../../../src/App-Services/Add-VNet-integration-to-AppService.ps1)

# Links

- [Azure CLI - az-webapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-list)
- [Azure CLI - az-webapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/webapp/vnet-integration?view=azure-cli-latest#az-webapp-vnet-integration-add)
- [Azure CLI - az-webapp-restart](https://docs.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest#az-webapp-restart)
