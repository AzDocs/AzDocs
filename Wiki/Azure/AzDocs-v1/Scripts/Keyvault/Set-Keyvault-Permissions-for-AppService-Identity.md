[[_TOC_]]

# Description

This snippet allows you to set permissions for a given (existing) identity (any service principal will do, including managed identities) on the given (existing) keyvault.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                      | Required                        | Example Value                               | Description                                                                                                                                                                                                                                     |
| ------------------------------ | ------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AppServiceName                 | <input type="checkbox" checked> | `myapi-$(Release.EnvironmentName)`          | The name of the webapp.                                                                                                                                                                                                                         |
| KeyvaultCertificatePermissions | <input type="checkbox">         | `get list update create`                    | Space separated list of permissions for certificates for the given user. Options: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update |
| KeyvaultKeyPermissions         | <input type="checkbox">         | `list get import create`                    | Space separated list of permissions for keys for the given user. Options: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey                                        |
| KeyvaultName                   | <input type="checkbox" checked> | `mykeyvault`                                | This is the keyvault name to use.                                                                                                                                                                                                               |
| KeyvaultSecretPermissions      | <input type="checkbox">         | `get list purge recover`                    | Space separated list of permissions for secrets for the given user. Options: backup, delete, get, list, purge, recover, restore, set                                                                                                            |
| KeyvaultStoragePermissions     | <input type="checkbox">         | `get list listas update set setas`          | Space separated list of permissions for storage for the given user. Options: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update                                                 |
| AppServiceResourceGroupName    | <input type="checkbox" checked> | `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your AppService resides in                                                                                                                                                                                              |
| AppServiceSlotName             | <input type="checkbox">         | `staging`                                   | OPTIONAL: Name of the webapp staging slot to bind                                                                                                                                                                                               |
| ApplyToAllSlots                | <input type="checkbox">         | `$true`                                     | Apply the permissions to all slots. Defaults to false.                                                                                                                                                                                          |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Set Keyvault Permissions for AppService Identity"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Keyvault/Set-Keyvault-Permissions-for-AppService-Identity.ps1"
    arguments: "-AppServiceName '$(AppServiceName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -KeyvaultCertificatePermissions '$(KeyvaultCertificatePermissions)' -KeyvaultKeyPermissions '$(KeyvaultKeyPermissions)' -KeyvaultSecretPermissions '$(KeyvaultSecretPermissions)' -KeyvaultStoragePermissions '$(KeyvaultStoragePermissions)' -KeyvaultName '$(KeyvaultName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../src/Keyvault/Set-Keyvault-Permissions-for-AppService-Identity.ps1)

# Links

[Azure CLI - az-webapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest#az-webapp-identity-show)

[Azure CLI - az-keyvault-set-policy](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az-keyvault-set-policy)
