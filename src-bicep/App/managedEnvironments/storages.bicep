/*
.SYNOPSIS
Creating a storages resources
.DESCRIPTION
A storages resources can be used for volumes for a container app.
.EXAMPLE
<pre>
module storages 'br:contosoregistry.azurecr.io/app/managedenvironments/storages:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'storages')
  params: {
    managedEnvironmentName: managedEnvironmentName
    storageAccountFileShareName: 'myfileshare'
    // Option A: pass a plain account key (existing behavior)
    // storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value

    // Option B: reference a Key Vault secret by supplying `accountKeyVaultProperties`.
    // Expected shape: { identity: { type: 'UserAssigned', userAssignedIdentities: { '<id>': {} } } , keyVaultUrl: 'https://.../secrets/<secretName>' }
    // Example below assumes you have a user-assigned identity available as `uami` and a Key Vault secret.
    accountKeyVaultProperties: {
      identity: uami
      keyVaultUrl: 'https://mykv.vault.azure.net/secrets/myStorageKey'
    }
    storageAccountName: daprStorageAccountName
    location: location
  }
}
</pre>
<p>Creates a storages resource</p>
.LINKS
- [Bicep Microsoft.App/managedEnvironments storages](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2025-01-01/managedenvironments/storages?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name for the managed Environment for the Container App.')
param managedEnvironmentName string

@description('The name for the storages resource')
param storagesName string

@description('The type of storage to use: AzureFile (with account key) or NfsAzureFile (NFS v3 protocol)')
@allowed([
  'AzureFile'
  'NfsAzureFile'
])
param storageType string = 'AzureFile'

@description('The account key to use on the storage account (required for AzureFile type if accountKeyVaultProperties is not provided)')
@secure()
param storageAccountKey string = ''

@description('the storage account name. This should be pre-existing.')
param storageAccountName string

@description('the fileshare name in the storage account.')
param storageAccountFileShareName string

@description('Since you need to use a shareName (Azure File Share Storage), accessMode should be set to either ReadWrite or ReadOnly.')
param storagesAccessMode string = 'ReadWrite'

@description('Properties to reference a Key Vault secret for the storage account key')
type AccountKeyVaultProperties = {
  //Resource ID of a managed identity to authenticate with Azure Key Vault, or System to use a system-assigned identity.
  identity: string
  // Full Key Vault secret URL, e.g. 'https://mykv.vault.azure.net/secrets/mySecret'
  keyVaultUrl: string
}

@description('Optional properties to reference the storage account key from Key Vault. If provided, this will be used instead of a plain account key.')
param accountKeyVaultProperties AccountKeyVaultProperties?

// ================================================= Resources =================================================
resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-07-01' existing = {
  name: managedEnvironmentName

  resource managedEnvironmentStorages 'storages@2025-07-01' = {
    name: storagesName
    properties: storageType == 'AzureFile'
      ? accountKeyVaultProperties != null
        ? {
            azureFile: {
              accountKeyVaultProperties: accountKeyVaultProperties
              accountName: storageAccountName
              shareName: storageAccountFileShareName
              accessMode: storagesAccessMode
            }
          }
        : {
            azureFile: {
              accountKey: storageAccountKey
              accountName: storageAccountName
              shareName: storageAccountFileShareName
              accessMode: storagesAccessMode
            }
          }
      : {
          nfsAzureFile: {
            server: storageAccountName
            shareName: storageAccountFileShareName
            accessMode: storagesAccessMode
          }
        }
  }
}
