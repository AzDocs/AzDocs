[[_TOC_]]

# Description

This snippet will import a JSON file into the AppConfiguration resource.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter             | Required                        | Example Value                            | Description                                                                                                                                              |
| --------------------- | ------------------------------- | ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AppConfigName         | <input type="checkbox" checked> | `myappconfig-$(Release.EnvironmentName)` | This is the app configuration name to use.                                                                                                               |
| Label                 | <input type="checkbox" checked> | `$(Release.EnvironmentName)`             | This label will be applied to all imported keyvaluepairs. Can be kept empty for no label.                                                                |
| JsonFilePath          | <input type="checkbox" checked> | `/some/path/appsettings.json`            | Path to the JSON file to be imported.                                                                                                                    |
| KeyValuePairSeparator | <input type="checkbox">         | `:`                                      | Delimiter for flattening the json or yaml file to key-value pairs.                                                                                       |
| KeyPrefix             | <input type="checkbox" checked> | `myapplicationname`                      | This prefix will be appended to the front of imported keys. With this prefix you can separate the configurations for different applications for example. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Import Json Configuration File"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    failOnStandardError: true
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Configuration/Import-Json-Configuration-File.ps1"
    arguments: "-AppConfigName '$(AppConfigName)' -Label '$(Label)' -JsonFilePath '$(JsonFilePath)' -KeyValuePairSeparator '$(KeyValuePairSeparator)' -KeyPrefix '$(KeyPrefix)'"
```

# Code

[Click here to download this script](../../../../src/App-Configuration/Import-Json-Configuration-File.ps1)

# Links

[Azure CLI - az appconfig kv import](https://docs.microsoft.com/en-us/cli/azure/appconfig/kv?view=azure-cli-latest#az_appconfig_kv_import)
