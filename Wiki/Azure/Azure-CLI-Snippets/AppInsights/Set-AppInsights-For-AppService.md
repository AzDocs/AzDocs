[[_TOC_]]

# Description

<font color="red">NOTE: This script is now legacy. Please use `Create-Application-Insights-Extension-for-WebApps-(codeless)` instead of this task.</font>

This snippet will add an existing AppInsights resource to your AppService.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppInsightsName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)-AppInsights` | The name of the AppInsights Resource. It's recommended to stick to alphanumeric & hyphens for this. |
| AppInsightsResourceGroupName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group the AppInsights resource will be created in |
| AppServiceName | -[x] | `my-appservice` | The name of your App Service. |
| AppInsightsResourceGroupName | -[ ] | `my-appservice-resourcegroup-name` | The resourcegroup your appservice resides in. |
| AppServiceSlotName | -[] | `staging` | Optional: The slotname of your deployment slot. |
| ApplyToAllSlots | -[] | `$true` | If the setting has to be applied to all slots. Has a default value of $false. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Set AppInsights For AppService'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/AppInsights/Set-AppInsights-For-AppService.ps1'
               arguments: "-AppInsightsName '$(AppInsightsName)' -AppServiceName '$(AppServiceName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppInsightsResourceGroupName '$(AppInsightsResourceGroupName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/AppInsights/Set-AppInsights-For-AppService.ps1)

# Links

- [Azure CLI - az webapp config appsettings set](https://docs.microsoft.com/en-us/cli/azure/webapp/config/appsettings?view=azure-cli-latest)
