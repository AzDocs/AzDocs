[[_TOC_]]

# Description

This snippet will set the appsettings on your appservice. It allows you to set the settings for specific slots or all slots.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServiceResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | `App-Service-name` | Name of the app service to set the whitelist on. |
| AppServiceAppSettings | `@("settingname=settingvalue"; "anothersettingname=anothersettingvalue")` and/or `@moreSettings.json` | Powershell string array with settings, Also you can load a file with JSON settings. |
| AppServiceDeploymentSlotName | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set AppSettings For AppService"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Set-AppSettings-For-AppService.ps1"
    arguments: "-AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceAppSettings $(AppServiceAppSettings) -AppServiceDeploymentSlotName '$(AppServiceDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../../src/App-Services/Set-AppSettings-For-AppService.ps1)
