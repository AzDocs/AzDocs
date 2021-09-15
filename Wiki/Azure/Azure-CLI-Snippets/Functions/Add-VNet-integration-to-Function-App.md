- [Description](#description)
- [Parameters](#parameters)
- [YAML](#yaml)
- [Code](#code)
- [Links](#links)

# Description

This snippet will add vnet-integration to an existing function app.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter                            | Required                        | Example Value                               | Description                                                                                                                                                                                                                                                                                                |
| ------------------------------------ | ------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FunctionAppName                      | <input type="checkbox" checked> | `myteamtestapi$(Release.EnvironmentName)`   | The name of the function app. It's recommended to stick to lowercase alphanumeric characters.                                                                                                                                                                                                              |
| FunctionAppVnetIntegrationVnetName   | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`        | The name of the VNET where to place the vnet-integration in.                                                                                                                                                                                                                                               |
| FunctionAppResourceGroupName         | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in                                                                                                                                                                                                                                                        |
| FunctionAppVnetIntegrationSubnetName | <input type="checkbox" checked> | `app-subnet-4`                              | The name of the subnet to place the vnet-integration in. Note: Adding a function app vnetintegration to a subnet will delegate that entire subnet to the function apps. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |
| FunctionAppServiceDeploymentSlotName | <input type="checkbox">         | `staging`                                   | OPTIONAL By default the production slot is used, use this variable to use a different slot.                                                                                                                                                                                                                |
| ApplyToAllSlots                      | <input type="checkbox">         | `$true`/`$false`                            | Applies the current script to all slots revolving this resource                                                                                                                                                                                                                                            |
| RouteAllTrafficThroughVnet                | <input type="checkbox" checked> | `$true`/`$false`                            | If true, all the traffic is routed through the vnet. If false only [Private Address Space](https://datatracker.ietf.org/doc/html/rfc1918#section-3) is routed through the vnet.                                                                                                                            |
# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add VNet integration to Function App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Add-VNet-integration-to-Function-App.ps1"
    arguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppVnetIntegrationVnetName '$(FunctionAppVnetIntegrationVnetName)' -FunctionAppVnetIntegrationSubnetName '$(FunctionAppVnetIntegrationSubnetName)' -FunctionAppServiceDeploymentSlotName '$(FunctionAppServiceDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots) -RouteAllTrafficThroughVnet $true"
```

# Code

[Click here to download this script](../../../../src/Functions/Add-VNet-integration-to-Function-App.ps1)

# Links

- [Azure CLI - az-functionapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-list)
- [Azure CLI - az-functionapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-add)
- [Azure CLI - az-functionapp-restart](https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-restart)
