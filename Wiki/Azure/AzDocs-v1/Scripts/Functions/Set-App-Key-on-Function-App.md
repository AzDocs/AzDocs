[[_TOC_]]

# Description

This snippet will set an app key on your functionapp. It allows you to set the app keys for specific slots or all slots.
The slot you apply this to will have to be started, otherwise the script will fail (usually production slot if DeploymentSlotName is not set).
If ApplyToAllSlots is set to true, the script will check if the additional slots are stopped, if they are it will attempt to start the slot, make the change and stop it again.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Required | Example Value | Description |
| ----------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------- |
| FunctionAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the FunctionApp resides in. |
| FunctionAppName | <input type="checkbox" checked> | `FunctionApp-name` | Name of the FunctionApp to set the whitelist on. |
| FunctionAppAppKeyName | <input type="checkbox" checked> | `exampleKeyName` | Name of the app key. |
| FunctionAppAppKeyType | <input type="checkbox"> | `functionKeys`/`masterKey`/`systemKey` | Type of the app key. Defaults to functionKeys |
| FunctionAppDeploymentSlotName | <input type="checkbox"> | `staging` | Name of the slot to apply the app key to |
| ApplyToAllSlots | <input type="checkbox"> | `$true` | The slot to apply the app key to |
| RetryApplyToAllSlotsCount | <input type="checkbox"> | `5` | Retry count for applying the key to a slot when ApplyToAllSlots is true. Defaults to 3. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set AppSettings For Function App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Set-App-Key-to-Function-App.ps1"
    arguments: >
      -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' 
      -FunctionAppName '$(FunctionAppName)' 
      -FunctionAppAppKeyName $(FunctionAppAppKeyName) 
      -FunctionAppAppKeyType $(FunctionAppAppKeyType) 
      -FunctionAppDeploymentSlotName $(FunctionAppDeploymentSlotName) 
      -ApplyToAllSlots $(ApplyToAllSlots) 
      -RetryApplyToAllSlotsCount $(RetryApplyToAllSlotsCount)
```

# Code

[Click here to download this script](../../../../src/Functions/Set-App-Key-to-Function-App.ps1)

[Click here to go to azure cli documentation](https://docs.microsoft.com/en-us/cli/azure/functionapp/keys?view=azure-cli-latest#az-functionapp-keys-set)
