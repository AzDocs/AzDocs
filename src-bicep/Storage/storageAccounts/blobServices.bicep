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
  retentionInDays: 30
}

@description('Whether or not to enable versioning on the blobservices.')
param isVersioningEnabled bool = true

param deleteRetentionPolicy object = {
  allowPermanentDelete: false
  days: 31
  enabled: true
}

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
  }
}

@description('Upsert the blob container.')
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: '${storageAccount.name}/default/${blobContainerName}'
  properties: {}
}

@description('Output the storage account container name.')
output blobContainerName string = storageAccountContainer.name
