[[_TOC_]]

# Description

This snippet will add an existing AppInsights resource to your Function App.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppInsightsName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)-AppInsights` | The name of the AppInsights Resource. It's recommended to stick to alphanumeric & hyphens for this. |
| AppInsightsResourceGroupName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group the AppInsights resource will be created in |
| FunctionAppName | -[x] | `my-appservice` | The name of your Function App. |
| FunctionAppResourceGroupName | -[ ] | `my-functionapp-resourcegroup-name` | The resourcegroup your function app resides in. |
| AppServiceSlotName | -[] | `staging` | Optional: The slotname of your deployment slot. |
| ApplyToAllSlots | -[] | `$true` | If the setting has to be applied to all slots. Has a default value of $false. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Set AppInsights For FunctionApp'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/AppInsights/Set-AppInsights-For-FunctionApp.ps1'
               arguments: "-AppInsightsName '$(AppInsightsName)' -AppInsightsResourceGroupName '$(AppInsightsResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/AppInsights/Set-AppInsights-For-FunctionApp.ps1)

# Links

- [Azure CLI - az functionapp config appsettings set](https://docs.microsoft.com/nl-nl/cli/azure/functionapp/config/appsettings?view=azure-cli-latest)
