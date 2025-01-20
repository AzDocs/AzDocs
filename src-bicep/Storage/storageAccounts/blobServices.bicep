/*
.SYNOPSIS
Creating a blob container in a storage account.
.DESCRIPTION
Creating a blob container in a storage account.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/blobservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'blob')
  params: {
    storageAccountName: storageAccountName
    blobContainerName: 'blobcontainername'
  }
}
</pre>
<p>Creates a blob container with the name blobcontainername in an existing storage account.</p>
.LINKS
- [Bicep Storage Blob Container](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================

@description('The name of the blob container to create.')
@minLength(3)
@maxLength(63)
param blobContainerName string

@description('The name of the storage account to create the blob container in. This should be pre-existing.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('The restore policy for the blob container.')
param restorePolicy object = {
  days: 30
  enabled: true
}

@description('The change feed policy for the blobservices.')
param changeFeed object = {
  enabled: true
  retentionInDays: 31
}

@description('Whether or not to enable versioning on the blobservices.')
param isVersioningEnabled bool = true

param deleteRetentionPolicy object = {
  allowPermanentDelete: false
  days: 31
  enabled: true
}

@description('The blob service properties for container soft delete.')
param containerDeleteRetentionPolicy object = {
  allowPermanentDelete: false
  days: 31
  enabled: true
}


// ================================================= Resources =================================================
@description('Fetch the existing storage account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    restorePolicy: restorePolicy
    isVersioningEnabled: isVersioningEnabled
    changeFeed: changeFeed
    deleteRetentionPolicy: deleteRetentionPolicy
    containerDeleteRetentionPolicy: containerDeleteRetentionPolicy
  }
}

@description('Upsert the blob container.')
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  parent: blobServices
  name: blobContainerName
  properties: {}
}

@description('Output the storage account container name.')
output blobContainerName string = storageAccountContainer.name
