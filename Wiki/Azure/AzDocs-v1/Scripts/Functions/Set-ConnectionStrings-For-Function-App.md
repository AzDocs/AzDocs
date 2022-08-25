[[_TOC_]]

# Description

This snippet will set the appsettings on your functionapp. It allows you to set the settings for specific slots or all slots.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Example Value | Description |
|--|--|--|
| FunctionAppResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the FunctionApp resides in. |
| FunctionAppName | `FunctionApp-name` | Name of the app service to set the whitelist on. |
| FunctionAppConnectionStringsInJson | `'[{"name": "MyConnectionString", "value": "Server=10.0.0.123;Initial Catalog=MyDatabase;User ID=$(DbUserName);Password=$(DbPassword);", "type": "Custom"}, {"name": "MyConnectionString2", "value": "Server=10.0.0.124;Initial Catalog=MyDatabase2;User ID=$(DbUserName);Password=$(DbPassword);", "type": "SQLAzure"}]'`| ConnectionStrings in JSON format. Expected format is an array with connectionstrings which each have `name`, `value` & `type`. type should be one of the following: `ApiHub`, `Custom`, `DocDb`, `EventHub`, `MySql`, `NotificationHub`, `PostgreSQL`, `RedisCache`, `SQLAzure`, `SQLServer`, `ServiceBus`. Make sure to enclose the JSON with single quotes (`'`) |
| FunctionAppDeploymentSlotName | `staging` | Name of the deployment slot to add ip whitelisting to. This is an optional field. |
| ApplyToAllSlots | `$true`/`$false` | Applies the current script to all slots revolving this resource |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set ConnectionStrings For Function App"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/Set-ConnectionStrings-For-Function-App.ps1"
    arguments: "-FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' -FunctionAppName '$(FunctionAppName)' -FunctionAppConnectionStringsInJson $(FunctionAppConnectionStringsInJson) -FunctionAppDeploymentSlotName '$(FunctionAppDeploymentSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/App-Services/Set-ConnectionStrings-For-FunctionApp.ps1)
