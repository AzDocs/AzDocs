/*
.SYNOPSIS
Configuring file services on an existing storage account.
.DESCRIPTION
Configures the file service (Microsoft.Storage/storageAccounts/fileServices) on an existing
storage account. Supports NFS protocol settings such as encryption-in-transit configuration.
.EXAMPLE
<pre>
module fileServices 'br:contosoregistry.azurecr.io/storage/storageaccounts/fileservices:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'fs')
  params: {
    storageAccountName: storageAccountName
    nfsEncryptionInTransitRequired: false
  }
}
</pre>
<p>Configures file services with NFS encryption in transit disabled, for use with private endpoints.</p>
.LINKS
- [Bicep Storage File Services](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing storage account to configure file services on.')
param storageAccountName string

@description('The name of the file service. Only \'default\' is supported by Azure.')
param fileServiceName string = 'default'

@description('''
If true, NFS connections require encryption in transit (channel encryption).
Set to false when using NFS with private endpoints, where network-layer security is provided
by the private endpoint and in-transit encryption at the protocol level is not required.
Defaults to true.
''')
param nfsEncryptionInTransitRequired bool = true

// ================================================= Resources =================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: fileServiceName
  properties: {
    protocolSettings: {
      nfs: {
        encryptionInTransit: {
          required: nfsEncryptionInTransitRequired
        }
      }
    }
  }
}

// ================================================= Outputs =================================================
@description('The resource ID of the file service.')
output fileServiceId string = fileServices.id

@description('The name of the file service.')
output fileServiceName string = fileServices.name
