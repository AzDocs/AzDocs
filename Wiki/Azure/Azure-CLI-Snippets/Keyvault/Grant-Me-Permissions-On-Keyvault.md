[[_TOC_]]

# Description
This snippet allows you to give the executing user permissions (any service principal will do) on the given (existing) keyvault.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter | Example Value | Description |
|--|--|--|
| KeyvaultName | `mykeyvault` | This is the keyvault name to use. |
| KeyvaultResourceGroupName | `myresourcegroup` | This is the resourcegroupname where the (pre-existing) keyvault resides in. |
| KeyvaultCertificatePermissions | `get list update create` | Space separated list of permissions for certificates for the given user. Options: backup, create, delete, deleteissuers, get, getissuers, import, list, listissuers, managecontacts, manageissuers, purge, recover, restore, setissuers, update |
| KeyvaultKeyPermissions  | `list get import create` | Space separated list of permissions for keys for the given user. Options: backup, create, decrypt, delete, encrypt, get, import, list, purge, recover, restore, sign, unwrapKey, update, verify, wrapKey |
| KeyvaultSecretPermissions | `get list purge recover` | Space separated list of permissions for secrets for the given user. Options: backup, delete, get, list, purge, recover, restore, set |
| KeyvaultStoragePermissions  | `get list listas update set setas` | Space separated list of permissions for storage for the given user. Options: backup, delete, deletesas, get, getsas, list, listsas, purge, recover, regeneratekey, restore, set, setsas, update |

# Code
[Click here to download this script](../../../../src/Keyvault/Grant-Me-Permissions-On-Keyvault.ps1)

# Links

[Azure CLI - az account show](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az_account_show)

[Azure CLI - az keyvault set-policy](https://docs.microsoft.com/en-us/cli/azure/keyvault?view=azure-cli-latest#az_keyvault_set_policy)
