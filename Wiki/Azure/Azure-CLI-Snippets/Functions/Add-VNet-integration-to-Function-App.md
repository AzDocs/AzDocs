[[_TOC_]]

# Description

This snippet will add vnet-integration to an existing function app.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppName | `myteamtestapi$(Release.EnvironmentName)` | The name of the function app. It's recommended to stick to lowercase alphanumeric characters. |
| FunctionAppVnetIntegrationName | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET where to place the vnet-integration in. |
| FunctionAppResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the function app resides in
| FunctionAppVnetIntegrationSubnetName | `app-subnet-4` | The name of the subnet to place the vnet-integration in. Note: Adding a function app vnetintegration to a subnet will delegate that entire subnet to the function apps. This means that no other resources can be placed inside this vnet (even no other appserviceplans). This has to be an empty subnet. |
| FunctionAppServiceDeploymentSlotName | `staging` | OPTIONAL By default the production slot is used, use this variable to use a different slot. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# YAML

```yaml
       - task: AzureCLI@2
           displayName: 'Add VNet integration to Function App'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Functions/Add-VNet-integration-to-Function-App.ps1'
               arguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppVnetIntegrationName '$(FunctionAppVnetIntegrationName)' -FunctionAppVnetIntegrationSubnetName '$(FunctionAppVnetIntegrationSubnetName)' -FunctionAppServiceDeploymentSlotName '$(FunctionAppServiceDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots) -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppVnetIntegrationName '$(FunctionAppVnetIntegrationName)' -FunctionAppVnetIntegrationSubnetName '$(FunctionAppVnetIntegrationSubnetName)' -FunctionAppServiceDeploymentSlotName '$(FunctionAppServiceDeploymentSlotName)'"
```

# Code

[Click here to download this script](../../../../src/Functions/Add-VNet-integration-to-Function-App.ps1)

# Links

- [Azure CLI - az-functionapp-vnet-integration-list](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-list)
- [Azure CLI - az-functionapp-vnet-integration-add](https://docs.microsoft.com/en-us/cli/azure/functionapp/vnet-integration?view=azure-cli-latest#az-functionapp-vnet-integration-add)
- [Azure CLI - az-functionapp-restart](https://docs.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest#az-functionapp-restart)
