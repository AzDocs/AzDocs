/*
.SYNOPSIS
Creating Azure App Configuration
.DESCRIPTION
This module is used for creating Azure App Configuration
.EXAMPLE
<pre>
module configurationStore 'br:contosoregistry.azurecr.io/appconfiguration/configurationStores:latest' = {
  name: '${take(deployment().name, 57)}-acs'
  params:{
    configurationStoreName: configurationStoreName
    location: location
    skuName: 'Standard'
    identity: {
      type: 'SystemAssigned'
    }
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: true
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    configurationValues: [
      {
        key: 'EmailAddress'
        value: 'dev@example.com'
        label: 'Development'
      }
      {
        key: 'EmailAddress'
        value: 'prd@example.com'
        label: 'Production'
      }
    ]
  }
}
</pre>
.LINKS
- [Bicep Microsoft.AppConfiguration configurationStores](https://learn.microsoft.com/en-us/azure/templates/microsoft.appconfiguration/configurationstores?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('''
The name of the App Configuration store to upsert
Restrictions:
- Name must be between 5 and 50 characters and may only contain alphanumeric characters and -
- Name may not contain the sequence: ---
''')
@minLength(5)
@maxLength(50)
param configurationStoreName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Specifies whether the SKU for the configuration store.')
@allowed([
  'Free'
  'Standard'
])
param skuName string = 'Standard'

@discriminator('type')
type IdentityType = {
  type: 'SystemAssigned'
} | {
  type: 'UserAssigned'
  userAssignedIdentities: {}
} | {
  type: 'None'
}

@description('Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).')
param identity IdentityType = {
  type: 'SystemAssigned'
}

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Property to specify whether the store will accept traffic from public internet. If set to \'Disabled\' all traffic except private endpoint traffic will be blocked.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''
Indicates whether requests using non-AAD authentication are blocked.
''')
param disableLocalAuth bool = true

@description('Indicates whether purge protection should be enabled.')
param enablePurgeProtection bool = true

@description('The soft-delete retention for keeping items after deleting them.')
@minValue(1)
@maxValue(7)
param softDeleteRetentionInDays int = 7

@description('The configuration values to add to the App Configuration store. Provide an empty string for the \'label\' property if a label is not required.')
param configurationValues {
  key: string
  value: string
  label: string?
  contentType: string?
}[] = []

resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2023-09-01-preview' = {
  name: configurationStoreName
  location: location
  sku: {
    name: skuName
  }
  identity: identity
  tags: tags
  properties: {
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    enablePurgeProtection: enablePurgeProtection
    softDeleteRetentionInDays: softDeleteRetentionInDays
  }

  resource configurationStoreValue 'keyValues' = [for cv in configurationValues: {
    name: '${replace(uriComponent(cv.key), '%', '~')}${!empty(cv.?label) ? '$${cv.label}' : ''}'
    properties: {
      contentType: cv.?contentType
      value: cv.value
    }
  }]
}

@description('The configuration store name.')
output configurationStoreName string = configurationStore.name
@description('The configuration store resource ID.')
output configurationStoreId string = configurationStore.id
@description('The system assigned identity principal ID.')
output configurationStorePrincipalId string = identity.type == 'SystemAssigned'
  ? configurationStore.identity.principalId
  : ''
