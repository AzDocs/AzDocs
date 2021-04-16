[[_TOC_]]

# Description
This snippet will link an App Configuration key to a Keyvault Secret.

<font color="red">NOTE: At the time of writing: If you are using vnet whitelisting or private endpoints on your keyvault, you can not link your app config key to a keyvault secret due to network technical limitations.</font>

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| AppConfigName | `myappconfig-$(Release.EnvironmentName)` | This is the app configuration name to use. |
| AppConfigKeyName | `mykeyinappconfig` | The name of the key you want to use in App Configuration. |
| KeyVaultName | `mykeyvault$(Release.EnvironmentName)` | The name of the keyvault where your secret resides in. |
| KeyVaultSecretName | `mysecretname` | The name of the secret which you want to reference to. |
| Label | `$(Release.EnvironmentName)` | The label to add to this key. Generally this will be the environmentname, null or Default. |

# Code
[Click here to download this script](../../../../src/App-Configuration/Link-AppConfig-Key-To-Keyvault-Secret.ps1)

# Links

[Azure CLI - az keyvault secret list](https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest#az_keyvault_secret_list)

[Azure CLI - az appconfig kv set-keyvault](https://docs.microsoft.com/en-us/cli/azure/appconfig/kv?view=azure-cli-latest#az_appconfig_kv_set_keyvault)
