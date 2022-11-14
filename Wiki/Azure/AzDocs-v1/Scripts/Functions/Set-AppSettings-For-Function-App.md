[[_TOC_]]

# Description

This snippet will set the appsettings on your functionapp. It allows you to set the settings for specific slots or all slots.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the FunctionApp resides in. |
| FunctionAppName | `FunctionApp-name` | Name of the FunctionApp to set the whitelist on. |
| FunctionAppAppSettings | `@("settingname=settingvalue"; "anothersettingname=anothersettingvalue")` and/or `@moreSettings.json` | Powershell string array with settings, Also you can load a file with JSON settings. |
| FunctionAppDeploymentSlotName | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set AppSettings For Function App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Set-AppSettings-For-Function-App.ps1"
    arguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppAppSettings $(FunctionAppAppSettings) -FunctionAppDeploymentSlotName '$(FunctionAppDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../../src/App-Services/Set-AppSettings-For-FunctionApp.ps1)
