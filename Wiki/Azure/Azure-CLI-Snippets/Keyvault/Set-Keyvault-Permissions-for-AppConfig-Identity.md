[[_TOC_]]

# Description

This snippet allows you to set permissions for a given (existing) identity (any service principal will do, including managed identities) on the given (existing) keyvault.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| appConfigName | `myappconfig$(Release.EnvironmentName)` | The name of the App Configuration. |
| keyvaultCertificatePermissions | `get list update create` | Space separated list of permissions for certificates for the given user. Options: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update |
| keyvaultKeyPermissions  | `list get import create` | Space separated list of permissions for keys for the given user. Options: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey |
| keyvaultName | `mykeyvault` | This is the keyvault name to use. |
| keyvaultSecretPermissions | `get list purge recover` | Space separated list of permissions for secrets for the given user. Options: backup, delete, get, list, purge, recover, restore, set |
| keyvaultStoragePermissions  | `get list listas update set setas` | Space separated list of permissions for storage for the given user. Options: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update |
| appConfigResourceGroupName| `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your AppConfig resides in |
| AppServiceSlotName | `staging` | OPTIONAL: Name of the webapp staging slot to bind |

# Code

[Click here to download this script](../../../../src/Keyvault/Set-Keyvault-Permissions-for-AppConfig-Identity.ps1)

# Links

[Azure CLI - az appconfig identity show](https://docs.microsoft.com/en-us/cli/azure/appconfig/identity?view=azure-cli-latest#az_appconfig_identity_show)

[Azure CLI - az keyvault set-policy](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_set_policy)
