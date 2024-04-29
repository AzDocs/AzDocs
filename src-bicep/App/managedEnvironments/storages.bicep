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
    storageAccountKey: listKeys(resourceId('Microsoft.Storage/storageAccounts/', storageAccount.name), '2021-09-01').keys[0].value
    storageAccountName: daprStorageAccountName
    location: location
  }
}
</pre>
<p>Creates a storages resource</p>
.LINKS
- [Bicep Microsoft.App/managedEnvironments storages](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments/storages?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name for the managed Environment for the Container App.')
param managedEnvironmentName string

@description('The name for the storages resource')
param storagesName string = 'azurefilestorage'

@description('The account key to use on the storage account')
@secure()
param storageAccountKey string

@description('the storage account name. This should be pre-existing.')
param storageAccountName string

@description('the fileshare name in the storage account.')
param storageAccountFileShareName string

@description('Since you need to use a shareName (Azure File Share Storage), accessMode should be set to either ReadWrite or ReadOnly.')
param storagesAccessMode string = 'ReadWrite'

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: managedEnvironmentName

  resource managedEnvironmentStorages 'storages@2022-03-01' = {
    name: storagesName
    properties: {
      azureFile: {
        accountKey: storageAccountKey
        accountName: storageAccountName
        shareName: storageAccountFileShareName
        accessMode: storagesAccessMode
      }
    }
  }
}
