[[_TOC_]]

# Description

This snippet will create a key inside the keyvault if it doesn't exist yet.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter          | Required                        | Example Value                           | Description                                                                                                 |
| ------------------ | ------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| KeyvaultName       | <input type="checkbox" checked> | `mykeyvault-$(Release.EnvironmentName)` | This is the keyvault name to use.                                                                           |
| KeyName            | <input type="checkbox" checked> | `oneofmysecretkeys`                     | This is the keyname to use.                                                                                 |
| KeyExpiresInDays   | <input type="checkbox">         | `397`                                   | This is the amount of days before the key will expire. Defauls to 397 and should be equal or less than 397. |
| KeyNotBeforeInDays | <input type="checkbox">         | `15`                                    | This is the amount of days before the key will be active.                                                   |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Keyvault Key"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Keyvault/Create-Keyvault-Key.ps1"
    arguments: "-KeyVaultName '$(KeyVaultName)' -KeyName '$(KeyName)' -KeyExpiresInDays '$(KeyExpiresInDays)' -KeyNotBeforeInDays '$(KeyNotBeforeInDays)'"
```

# Code

[Click here to download this script](../../../../../src/Keyvault/Create-Keyvault-Key.ps1)

# Links

[Azure CLI - az-keyvault-key-show](https://docs.microsoft.com/en-us/cli/azure/keyvault/key?view=azure-cli-latest#az-keyvault-key-show)

[Azure CLI - az-keyvault-key-create](https://docs.microsoft.com/en-us/cli/azure/keyvault/key?view=azure-cli-latest#az-keyvault-key-create)
