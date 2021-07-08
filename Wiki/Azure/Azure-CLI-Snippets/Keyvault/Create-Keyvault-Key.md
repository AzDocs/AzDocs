[[_TOC_]]

# Description

This snippet will create a key inside the keyvault if it doesn't exist yet.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter    | Example Value                           | Description                       |
| ------------ | --------------------------------------- | --------------------------------- |
| KeyvaultName | `mykeyvault-$(Release.EnvironmentName)` | This is the keyvault name to use. |
| KeyName      | `oneofmysecretkeys`                     | This is the keyname to use.       |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Create Keyvault Key'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Keyvault/Create-Keyvault-Key.ps1'
               arguments: "-KeyVaultName '$(KeyVaultName)' -KeyName '$(KeyName)'"
```

# Code

[Click here to download this script](../../../../src/Keyvault/Create-Keyvault-Key.ps1)

# Links

[Azure CLI - az-keyvault-key-show](https://docs.microsoft.com/en-us/cli/azure/keyvault/key?view=azure-cli-latest#az-keyvault-key-show)

[Azure CLI - az-keyvault-key-create](https://docs.microsoft.com/en-us/cli/azure/keyvault/key?view=azure-cli-latest#az-keyvault-key-create)
