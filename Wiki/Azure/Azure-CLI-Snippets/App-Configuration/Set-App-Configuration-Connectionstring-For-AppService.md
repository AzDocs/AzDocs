[[_TOC_]]

# Description

This snippet will set the connectionstring of the specified App Configuration for the specified App Service.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                   | Example Value                               | Description                                                                                  |
| --------------------------- | ------------------------------------------- | -------------------------------------------------------------------------------------------- |
| AppConfigName               | `myappconfig-$(Release.EnvironmentName)`    | The name of the app configuration resource.                                                  |
| AppConfigResourceGroup      | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your app configuration resides in.                                   |
| AppServiceName              | `myteamtestapi$(Release.EnvironmentName)`   | The name of the app service. It's recommended to stick to lowercase alphanumeric characters. |
| AppServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the app service resides in                                           |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Set App Configuration Connectionstring For AppService'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/App-Configuration/Set-App-Configuration-Connectionstring-For-AppService.ps1'
               arguments: "-AppConfigName '$(AppConfigName)' -AppConfigResourceGroupName '$(AppConfigResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceSlotName '$(AppServiceSlotName)' -ReadOnlyConnectionString '$(ReadOnlyConnectionString)'"
```

# Code

[Click here to download this script](../../../../src/App-Configuration/Set-App-Configuration-Connectionstring-For-AppService.ps1)

# Links

[Azure CLI - az appconfig credential list](https://docs.microsoft.com/en-us/cli/azure/appconfig/credential?view=azure-cli-latest#az_appconfig_credential_list)

[Azure CLI - az webapp config connection-string set](https://docs.microsoft.com/en-us/cli/azure/webapp/config/connection-string?view=azure-cli-latest#az_webapp_config_connection_string_set)
