[[_TOC_]]

# Description
This snippet allows you to set permissions for a given (existing) identity (any service principal will do, including managed identities) on the given (existing) keyvault.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| appServiceName | `myapi-$(Release.EnvironmentName)` | The name of the webapp. |
| keyvaultCertificatePermissions | `get list update create` | Space separated list of permissions for certificates for the given user. Options: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update |
| keyvaultKeyPermissions  | `list get import create` | Space separated list of permissions for keys for the given user. Options: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey |
| keyvaultName | `mykeyvault` | This is the keyvault name to use. |
| keyvaultSecretPermissions | `get list purge recover` | Space separated list of permissions for secrets for the given user. Options: backup, delete, get, list, purge, recover, restore, set |
| keyvaultStoragePermissions  | `get list listas update set setas` | Space separated list of permissions for storage for the given user. Options: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update |
| appServiceResourceGroupName| `MyTeam-TestApi-$(Release.EnvironmentName)` | The ResourceGroup where your AppService resides in |

# Code
[Click here to download this script](../../../../src/Keyvault/Set-Keyvault-Permissions-for-AppService-Identity.ps1)

# Links

[Azure CLI - az-webapp-identity-show](https://docs.microsoft.com/en-us/cli/azure/webapp/identity?view=azure-cli-latest#az-webapp-identity-show)

[Azure CLI - az-keyvault-set-policy](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az-keyvault-set-policy)
