[[_TOC_]]

# Description
This snippet will set the connectionstring of the specified App Configuration for the specified App Service.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| appConfigName | `myappconfig-$(Release.EnvironmentName)` | The name of the app configuration resource. |
| appConfigResourceGroup | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your app configuration resides in. |
| appServiceName | `myteamtestapi$(Release.EnvironmentName)` | The name of the app service. It's recommended to stick to lowercase alphanumeric characters. |
| appServiceResourceGroupName | `MyTeam-TestApi-$(Release.EnvironmentName)` | The resourcegroup where the app service resides in |

# Code
[Click here to download this script](../../../../src/App-Configuration/Set-App-Configuration-Connectionstring-For-AppService.ps1)

# Links

[Azure CLI - az appconfig credential list](https://docs.microsoft.com/en-us/cli/azure/appconfig/credential?view=azure-cli-latest#az_appconfig_credential_list)

[Azure CLI - az webapp config connection-string set](https://docs.microsoft.com/en-us/cli/azure/webapp/config/connection-string?view=azure-cli-latest#az_webapp_config_connection_string_set)
