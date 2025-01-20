/*
.SYNOPSIS
Creating a table service in an existing storage account.
.DESCRIPTION
Creating a table service in an existing storage account.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/tableservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'tablesvc')
  params: {
    storageAccountName: storageAccountName
  }
}
</pre>
<p>Creates a tables services in an existing storage account.</p>
.LINKS
- [Bicep Storage Table Services](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
The name of the existing storage account.
''')
param storageAccountName string

@description('The name of the table service to create.')
param tableServiceName string = 'default'

// ================================================= Resources =================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  name: tableServiceName
  parent: storageAccount
  properties: {}
}

// ================================================= Outputs =================================================
output tableServiceId string = tableServices.id
