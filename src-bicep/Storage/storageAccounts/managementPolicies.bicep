/*
.SYNOPSIS
Creating a management policy for an existing storage account.
.DESCRIPTION
Creating a management policy for an existing storage account.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts/managementpolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 55), 'mgtmtpolicy')
  params: {
    storageAccountName: storageAccountName
    rules: [
      {
        enabled: true
        name: 'lifecycle_tiers'
        type: 'Lifecycle'
        definition: {
          actions: {
            baseBlob: {
              tierToCold: {
                daysAfterModificationGreaterThan: 30
              }
              tierToCool: {
                daysAfterModificationGreaterThan: 10
              }
            }
          }
          filters: {
            blobTypes: [
              'blockBlob'
            ]
          }
        }
      }
    ]
  }
}
</pre>
<p>Creates a blob container management policy for an existing storage account.</p>
.LINKS
- [Bicep Storage Management Policy](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/managementpolicies?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================

@maxLength(24)
@description('The name of the parent Storage Account which should be existing.')
param storageAccountName string

@description('Required. The Storage Account ManagementPolicies Rules.')
param rules array


// ================================================= Resources =================================================
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// lifecycle policy
resource managementPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    policy: {
      rules: rules
    }
  }
}

// ================================================= Outputs =================================================
@description('The resource ID of the deployed management policy.')
output resourceId string = managementPolicy.name

@description('The name of the deployed management policy.')
output name string = managementPolicy.name
