/*
.SYNOPSIS
Creating a file share in an existing file service.
.DESCRIPTION
Creating a file share in an existing file service.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/fileservices/shares:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'share')
  params: {
    storageAccountName: storageAccountName
    shareName: 'myfirstshare'
  }
}
</pre>
<p>Creates a file share with the name myfirstshare in an existing storage account.</p>
.LINKS
- [Bicep Storage File Services Shares](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices/shares?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the existing storage account.')
param storageAccountName string

@description('The name of the existing file service.')
param fileServiceName string = 'default'

@description('Specifies the name of the File Share. File share names must be between 3 and 63 characters in length and use numbers, lower-case letters and dash (-) only.')
@minLength(3)
@maxLength(63)
param fileShareName string

@description('''
Specifies the quota of the File Share in GB. Larger than 5 TB requires a storage account with large file shares feature enabled.
It is the provisioned capacity for the file share, ranging from 32 GiB to 262144 GiB.
''')
param shareQuota int = 5120

@description('Specifies the access tier of the File Share. Options are Hot, Cool, TransactionOptimized.')
@allowed([
  'Hot'
  'Cool'
  'Premium'
  'TransactionOptimized'
])
param accessTier string = 'TransactionOptimized'

@description('Specifies the enabled protocols of the File Share. Options are SMB, NFS.')
@allowed([
  'SMB'
  'NFS'
])
param enabledProtocols string = 'SMB'

@description('A set of name-value pairs that can be used to store additional information about the file share as metadata.')
param metadata object = {}

@description('Specifies the root squash setting for NFS shares. Options are NoRootSquash, RootSquash, AllSquash.')
@allowed([
  'NoRootSquash'
  'RootSquash'
  'AllSquash'
])
param rootSquash string = 'NoRootSquash'

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' existing = {
  name: storageAccountName

  resource fileServices 'fileServices@2025-06-01' existing = {
    name: fileServiceName
  }
}

resource fileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-06-01' = {
  parent: storageAccount::fileServices
  name: fileShareName
  properties: {
    shareQuota: shareQuota
    accessTier: accessTier
    enabledProtocols: enabledProtocols
    metadata: metadata
    rootSquash: enabledProtocols == 'NFS' ? rootSquash : null
  }
}
// ================================================= Outputs =================================================
output fileShareId string = fileshare.id
output fileShareName string = fileshare.name
