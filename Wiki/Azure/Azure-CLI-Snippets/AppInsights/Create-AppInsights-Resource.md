[[_TOC_]]

# Description

This snippet will add an AppInsights resource to a Resource Group. The az cli used is in preview, so keep an eye on possible changes as announced by Microsoft.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| AppInsightsName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)-AppInsights` | The name of the AppInsights Resource. It's recommended to stick to alphanumeric & hyphens for this. |
| AppInsightsResourceGroupName | -[x] | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group the AppInsights resource will be created in |
| AppInsightsLocation | -[x] | `West Europe`/`westeurope` | Defines the Azure Location for the App Insights resource to reside in (you can use `az account list-locations -o table` to get a list of locations you can use) |
| LogAnalyticsWorkspaceResourceId | -[ ] | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace that Application Insights can be linked to. |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Create AppInsights Resource'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/AppInsights/Create-AppInsights-Resource.ps1'
               arguments: "-AppInsightsName '$(AppInsightsName)' -AppInsightsResourceGroupName '$(AppInsightsResourceGroupName)' -AppInsightsLocation '$(AppInsightsLocation)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)'"
```

# Code

[Click here to download this script](../../../../src/AppInsights/Create-AppInsights-Resource.ps1)

# Links

- [Create AppInsights Resource](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-new-resource#create-an-application-insights-resource-1)

- [Azure CLI - az-extension-add](https://docs.microsoft.com/en-us/cli/azure/extension?view=azure-cli-latest#az-extension-add)

- [Azure CLI - az-monitor-app-insights-component-create](https://docs.microsoft.com/en-us/cli/azure/ext/application-insights/monitor/app-insights/component?view=azure-cli-latest#ext-application-insights-az-monitor-app-insights-component-create)

- [Azure CLI - az-resource-show](https://docs.microsoft.com/en-us/cli/azure/resource?view=azure-cli-latest#az-resource-show)
