[[_TOC_]]

# Description
This snippet will link an App Configuration key to a Keyvault Secret.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| appConfigName | `myappconfig-$(Release.EnvironmentName)` | This is the app configuration name to use. |
| appConfigKeyName | `mykeyinappconfig` | The name of the key you want to use in App Configuration. |
| keyVaultName | `mykeyvault$(Release.EnvironmentName)` | The name of the keyvault where your secret resides in. |
| keyVaultSecretName | `mysecretname` | The name of the secret which you want to reference to. |
| label | `$(Release.EnvironmentName)` | The label to add to this key. Generally this will be the environmentname, null or Default. |

# Code
[Click here to download this script](../../../../src/App-Configuration/Link-AppConfig-Key-To-Keyvault-Secret.ps1)

# Links

[Azure CLI - az keyvault secret list](https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest#az_keyvault_secret_list)

[Azure CLI - az appconfig kv set-keyvault](https://docs.microsoft.com/en-us/cli/azure/appconfig/kv?view=azure-cli-latest#az_appconfig_kv_set_keyvault)
