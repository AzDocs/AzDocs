@description('The name of the blob container to create.')
@minLength(3)
@maxLength(63)
param blobContainerName string

@description('The name of the storage account to create the blob container in. This should be pre-existing.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Fetch the existing storage account.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

@description('Upsert the blob container.')
resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageAccount.name}/default/${blobContainerName}'
  properties: {}
}

@description('Output the storage account container name.')
output blobContainerName string = storageAccountContainer.name
