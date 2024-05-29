/*
.SYNOPSIS
Adding a immutability policy to a blob container in a storage account.
.DESCRIPTION
Adding a immutability policy to a blob container in a storage account.
.EXAMPLE
<pre>
module policy 'br:contosoregistry.azurecr.io/storage/storageaccounts/blobservices/immutabilitypolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'impol')
  params: {
    storageAccountName: storageAccountName
    blobContainerName: 'blobcontainername'
    allowProtectedAppendWrites: true
    allowProtectedAppendWritesAll: true
    immutabilityPeriodSinceCreationInDays: 180
  }
}
</pre>
<p>Creates an immutabhility policy for an existing blob container with the name blobcontainername in an existing storage account with the name storageAccountName.</p>
.LINKS
- [Bicep Storage Blob Container Immutability Policy](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers/immutabilitypolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================

@description('The name of the blob container to create the policy for. This should be pre-existing.')
@minLength(3)
@maxLength(63)
param blobContainerName string

@description('The name of the storage account. This should be pre-existing.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The name of the immutability policy.')
param immutabilityPolicyName string = 'default'

@description('When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The \'allowProtectedAppendWrites\' and \'allowProtectedAppendWritesAll\' properties are mutually exclusive.')
param allowProtectedAppendWrites bool = false

@description('When enabled, new blocks can be written to both \'Append and Bock Blobs\' while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The \'allowProtectedAppendWrites\' and \'allowProtectedAppendWritesAll\' properties are mutually exclusive.')
param allowProtectedAppendWritesAll bool = true

@description('Immutability period since creation in days.')
param immutabilityPeriodSinceCreationInDays int = 180

@description('Fetch the existing storage account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

@description('Fetch the existing blob services.')
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' existing = {
  name: 'default'
  parent: storageAccount
}

@description('Fetch the existing blob container.')
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' existing = {
  parent: blobServices
  name: blobContainerName
}

@description('Create the immutability policy.')
resource immutabilityPolicy 'Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies@2023-01-01' = {
  name: immutabilityPolicyName
  parent: storageAccountContainer
  properties: {
    allowProtectedAppendWrites: allowProtectedAppendWrites
    allowProtectedAppendWritesAll: allowProtectedAppendWritesAll
    immutabilityPeriodSinceCreationInDays: immutabilityPeriodSinceCreationInDays
  }
}
