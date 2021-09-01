[[_TOC_]]

# Description

This snippet will create a key inside the keyvault if it doesn't exist yet.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter              | Required                                                                | Example Value                                    | Description                                                                                                                                                                                                              |
| ---------------------- | ----------------------------------------------------------------------- | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| KeyVaultName           | <input type="checkbox" checked>                                         | `mykeyvault-$(Release.EnvironmentName)`          | This is the keyvault name to use.                                                                                                                                                                                        |
| SecretName             | <input type="checkbox" checked>                                         | `oneofmysecrets`                                 | This is the secretname to use.                                                                                                                                                                                           |
| SecretDescription      | <input type="checkbox">                                                 | `my cool description of this very secret secret` | Add a description to your secret. Can be left blank.                                                                                                                                                                     |
| SecretExpiresInDays    | <input type="checkbox">                                                 | `397`                                            | This is the amount of days before the secret will expire. Defauls to 397 and should be equal or less than 397.                                                                                                           |
| SecretNotBeforeInDays  | <input type="checkbox">                                                 | `20`                                             | Add a "not before" date for your secret. Secret won't be used before this date.                                                                                                                                          |
| SecretFilePath         | <input type="checkbox" checked> File<br /><input type="checkbox"> Value | `/path/to/my/very/secret/file.txt`               | SEMI-OPTIONAL: Path to the secret file you want to upload. Use this parameter in combination with the fileEncoding parameter. If you use the filePath & fileEncoding option, you MUST leave the "value" parameter blank. |
| SecretFileFileEncoding | <input type="checkbox" checked> File<br /><input type="checkbox"> Value | `base64`                                         | SEMI-OPTIONAL: The encoding of the file you want to upload. Use this parameter in combination with the filePath parameter. If you use the filePath & fileEncoding option, you MUST leave the "value" parameter blank.    |
| SecretValue            | <input type="checkbox"> File<br /><input type="checkbox" checked> Value | `s0m3v3ry53cre7va1u3!!`                          | SEMI-OPTIONAL: The value of the secret you want to provision to the keyvault. If you use this parameter, you MUST leave the "filePath" & "fileEncoding" parameters blank.                                                |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Keyvault Secret"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Keyvault/Create-Keyvault-Secret.ps1"
    arguments: "-KeyVaultName '$(KeyVaultName)' -SecretName '$(SecretName)' -SecretDescription '$(SecretDescription)' -SecretExpiresInDays '$(SecretExpiresInDays)' -SecretNotBeforeInDays '$(SecretNotBeforeInDays)' -SecretFilePath '$(SecretFilePath)' -SecretFileFileEncoding '$(SecretFileFileEncoding)' -SecretValue '$(SecretValue)'"
```

# Code

[Click here to download this script](../../../../src/Keyvault/Create-Keyvault-Secret.ps1)

# Links

[Azure CLI - az keyvault secret set](https://docs.microsoft.com/en-us/cli/azure/keyvault/secret?view=azure-cli-latest#az_keyvault_secret_set)
