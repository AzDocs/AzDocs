[[_TOC_]]

# Description

Create a Azure Front Door profile.

# Parameters

| Parameter                       | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                       |
| ------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| FrontDoorProfileName            | <input type="checkbox" checked> | `azurefrontdoorprofile`                                                                                                                         | The name of the Front Door profile                                                                                                                |
| FrontDoorResourceGroup          | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`                                                                                                                 | The name of the resourcegroup the Front Door Profile resides in.                                                                                  |
| FrontDoorSku                    | <input type="checkbox" checked> | `Premium_AzureFrontDoor` / `Standard_AzureFrontDoor`                                                                                            | The front door sku.                                                                                                                               |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox" checked> | /subscriptions/`<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                             |
| DiagnosticSettingsLogs          | <input type="checkbox">         | `@('Requests';)`                                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.       |
| DiagnosticSettingsMetrics       | <input type="checkbox">         | `@('Requests';)`                                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled. |
| DiagnosticSettingsDisabled      | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch without a value(`-DiagnosticsettingsDisabled`).                |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Front Door Profile"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Create-Front-Door-Profile.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -FrontDoorSku '$(FrontDoorSku)'
        -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)'
        -ResourceTags '$(ResourceTags)'
        -DiagnosticSettingsLogs '$(DiagnosticSettingsLogs)'
        -DiagnosticSettingsMetrics '$(DiagnosticSettingsMetrics)'
        -DiagnosticSettingsDisabled '$(DiagnosticSettingsDisabled)'
```

# Code

[Click here to download this script](../../../../../src/Front-Door/Create-Front-Door-Profile.ps1)

# Links

[Azure CLI - az afd profile create](https://docs.microsoft.com/en-us/cli/azure/afd/profile?view=azure-cli-latest#az-afd-profile-create)