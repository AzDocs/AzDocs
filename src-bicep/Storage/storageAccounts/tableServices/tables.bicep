/*
.SYNOPSIS
Creating a table in an existing table service.
.DESCRIPTION
Creating a table in an existing table service.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/tableservices/tables:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'table')
  params: {
    storageAccountName: storageAccountName
    tableName: 'myfirsttable'
  }
}
</pre>
<p>Creates a table with the name myfirsttable in an existing storage account.</p>
.LINKS
- [Bicep Storage Table Services Table](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices/tables?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
The name of the existing storage account.
''')
param storageAccountName string

@description('The name of the existing table service.')
param tableServiceName string = 'default'

@description('The name of the table to create.')
param tableName string


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storageAccountName

  resource tableServices 'tableServices@2023-04-01' existing = {
    name: tableServiceName
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-04-01' = {
  name: tableName
  parent: storageAccount::tableServices
}
