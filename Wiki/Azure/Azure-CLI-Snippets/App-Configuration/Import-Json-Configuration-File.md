[[_TOC_]]

# Description
This snippet will import a JSON file into the AppConfiguration resource.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| appConfigName | `myappconfig-$(Release.EnvironmentName)` | This is the app configuration name to use. |
| label | `$(Release.EnvironmentName)` | This label will be applied to all imported keyvaluepairs. Can be kept empty for no label. |
| jsonFilePath | `/some/path/appsettings.json` | Path to the JSON file to be imported. |
| keyValuePairSeparator | `:` | Delimiter for flattening the json or yaml file to key-value pairs. |
| keyPrefix | `myapplicationname` | This prefix will be appended to the front of imported keys. With this prefix you can separate the configurations for different applications for example. |

# Code
[Click here to download this script](../../../../src/App-Configuration/Import-Json-Configuration-File.ps1)

# Links

[Azure CLI - az appconfig kv import](https://docs.microsoft.com/en-us/cli/azure/appconfig/kv?view=azure-cli-latest#az_appconfig_kv_import)
