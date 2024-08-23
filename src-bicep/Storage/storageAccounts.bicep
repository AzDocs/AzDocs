/*
.SYNOPSIS
Creating a storage account.
.DESCRIPTION
Creating a storage account.
.EXAMPLE
<pre>
module storageaccount 'br:contosoregistry.azurecr.io/storage/storageaccounts:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'stg')
  params: {
    storageAccountKind: 'StorageV2'
    storageAccountName: storageAccountName
    storageAccountSku: 'Standard_LRS'
    location: location
  }
}
</pre>
<p>Creates a storage account with the name storageAccountName</p>
.LINKS
- [Bicep Storage Account](https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================

@description('''
The name of the storage account to create.
Storage account name restrictions:
- Storage account names must be between 3 and 24 characters in length and may contain numbers and lowercase letters only.
- Your storage account name must be unique within Azure. No two storage accounts can have the same name.
''')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
Array of strings containing resource id\'s of the subnets you want to whitelist on this storage account.

For example:
[
  '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'
  '/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'
]
''')
param subnetIdsToWhitelist array = []

@description('''
Array of strings containing value of the Public IP you want to whitelist on this storage account. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.
''')
param publicIpsToWhitelist array = []

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
param logAnalyticsWorkspaceResourceId string = ''

@description('The SKU name to use for this storage account.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountSku string

@description('Indicates the type of storage account.')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param storageAccountKind string

@description('''
Required for storage accounts where kind = BlobStorage.
The access tier is used for billing. The 'Premium' access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.
''')
@allowed([
  'Cool'
  'Hot'
  'Premium'
])
param defaultBlobAccessTier string = 'Hot'

@description('Set the accessTier property on the storage account to null if the storageAccountSku is Premium_ZRS or Premium_LRS. Otherwise it will have the value of the defaultBlobAccessTier parameter.')
var effectiveBlobAccessTier = contains(storageAccountSku, 'Premium') ? null : defaultBlobAccessTier

@description('Allow or disallow public access to all blobs or containers in the storage account. The default interpretation is true for this property.')
param allowBlobPublicAccess bool = false

@description('Allow or disallow shared key access to the storage account. The default interpretation is false for this property.')
param allowSharedKeyAccess bool = false

@description('Set the minimum TLS version to be permitted on requests to storage.')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param storageAccountMinimumTlsVersion string = 'TLS1_2'

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('Allow or disallow public network access to Storage Account. Value is optional but if passed in, must be `Enabled` or `Disabled`.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
Optional. Provides the identity based authentication settings for Azure Files.
<details>
  <summary>Click to show example</summary>
<pre>
param azureFilesIdentityBasedAuthentication object = {
  directoryServiceOptions: 'AD'
  activeDirectoryProperties: {
    domainName: 'Contoso.com' //Global.DomainName
    netBiosDomainName: 'Contoso' //first(split(Global.DomainName, '.'))
    forestName: 'Contoso.com' // Global.DomainName
    domainGuid: '7bdbf663-36ad-43e2-9148-c142ace6ae24'
    domainSid: 'S-1-5-21-4189862783-2073351504-2099725206'
    azureStorageSid: 'S-1-5-21-4189862783-2073351504-2099725206-3101'
  }
}
</pre>
</details>
''')
param azureFilesIdentityBasedAuthentication object = {}

@description('Allow or disallow OAuth authentication to the storage account. The default interpretation is false for this property.')
param defaultToOAuthAuthentication bool = false

@description('Optional. If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
param enableNfsV3 bool = false

@description('Optional. If true, enables Secure File Transfer Protocol for the storage account. Requires enableHierarchicalNamespace to be true.')
param enableSftp bool = false

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Allow large file shares if sets to \'Enabled\'. It cannot be disabled once it is enabled. Only supported on locally redundant and zone redundant file shares. It cannot be set on FileStorage storage accounts (storage accounts for premium file shares).')
param largeFileSharesState string = 'Disabled'

@description('''
The name of the existing key vault to use for encryption and that stores the key. If this is set, the storage account will be encrypted with a key from the key vault.
Make sure to either grant the system assigned managed identity of the storage account or the user assigned managed identity of the storage account the correct RBAC or access policies on the Keyvault.
''')
param keyVaultName string = ''

@description('The resource group name for the user assigned managed identity.')
param userAssignedIdentityResourceGroupName string = resourceGroup().name

@description('The name of the user assigned managed identity to create for this storage account.')
param userAssignedIdentityName string = ''

@description('The resource group name for the user assigned managed identity.')
param keyVaultResourceGroupName string = resourceGroup().name

@description('The name of the key in the key vault to use for encryption. If this is set, the storage account will be encrypted with a key from the key vault.')
param keyName string = ''

@description('Determine that the storage account does not have an identity. If you want to use a cmk key,then you need to set this to false. Defaults to true for backwards compatibility.')
param overrideNoIdentity bool = true

@description('''
Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. 
Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.
''')
@allowed([
  'AzureServices'
  'None'
  'Logging'
  'Metrics'
  'Logging, Metrics'
  'Logging, Metrics, AzureServices'
])
param allowBypassAcl string = 'None'

@description('Account HierarchicalNamespace enabled if set to true. Can only be set at account creation time. ')
param isHnsEnabled bool = false

@description('Dealing with [issue:](https://github.com/Azure/azure-rest-api-specs/issues/18441)')
var hnsPropertyObject = isHnsEnabled ? {
  isHnsEnabled: true
} : {}

// ================================================= Variables =================================================
@description('''
One or more managed identities on this storage account. Defaults to no assigned managed identity. 
''')
var identity = (!empty(userAssignedIdentityName))
  ? {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${storageAccountUserAssignedManagedIdentity.id}': {}
      }
    }
  : overrideNoIdentity ? null : { type: 'SystemAssigned' }

@description('Build the needed object for the virtualNetworkRules based on the `subnetIdsToWhitelist` parameter.')
var virtualNetworkRules = [
  for subnetId in subnetIdsToWhitelist: {
    id: subnetId
    action: 'Allow'
  }
]

@description('Build the needed object for the virtualNetworkRules based on the `publicIpsToWhitelist` parameter.')
var ipRules = [
  for ip in publicIpsToWhitelist: {
    action: 'Allow'
    value: ip
  }
]

@description('Setting up the networkAcls and add rules if any are defined.')
var networkAcls = empty(virtualNetworkRules) && empty(ipRules)
  ? {
      defaultAction: 'Allow'
    }
  : {
      defaultAction: 'Deny'
      bypass: allowBypassAcl
      virtualNetworkRules: virtualNetworkRules
      ipRules: ipRules
    }

var supportsBlobService = storageAccountKind == 'BlockBlobStorage' || storageAccountKind == 'BlobStorage' || storageAccountKind == 'StorageV2' || storageAccountKind == 'Storage'
var supportsFileService = storageAccountKind == 'FileStorage' || storageAccountKind == 'StorageV2' || storageAccountKind == 'Storage'

// ================================================= Existing Resources =================================================
@description('''
the user assigned managed identity bound to the storage account. 
Add the required RBAC or access policy rights to this account on the Keyvault if it needs to be able to get, list, or decrypt the keys from the keyvault. 
For example if a cmk key is used.
''')
resource storageAccountUserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = if (!empty(userAssignedIdentityName)) {
  name: userAssignedIdentityName
  scope: resourceGroup(userAssignedIdentityResourceGroupName)
}

@description('The key vault to use for encryption. Needs to be pre-existing.')
resource cMKKeyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)

  resource cMKKey 'keys@2024-04-01-preview' existing = if (!empty(keyName)) {
    name: keyName
  }
}

// ================================================= Resources =================================================
@description('Upsert the storage account based on the given parameters.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: toLower(storageAccountName)
  identity: identity
  location: location
  kind: storageAccountKind
  tags: tags
  sku: {
    name: storageAccountSku
  }
  properties: union({
    accessTier: effectiveBlobAccessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    #disable-next-line BCP035
    azureFilesIdentityBasedAuthentication: !empty(azureFilesIdentityBasedAuthentication)
      ? azureFilesIdentityBasedAuthentication
      : null
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    encryption: {
      keySource: !empty(keyVaultName) ? 'Microsoft.Keyvault' : 'Microsoft.Storage'
      services: {
        blob: supportsBlobService
          ? {
              enabled: true
            }
          : null
        file: supportsFileService
          ? {
              enabled: true
            }
          : null
        table: {
          enabled: true
        }
        queue: {
          enabled: true
        }
      }
      keyvaultproperties: !empty(keyVaultName)
        ? {
            keyname: keyName
            keyvaulturi: cMKKeyVault.properties.vaultUri
          }
        : null
      identity: !empty(userAssignedIdentityName)
        ? {
            userAssignedIdentity: storageAccountUserAssignedManagedIdentity.id
          }
        : null
    }
    isNfsV3Enabled: enableNfsV3 ? enableNfsV3 : any('')
    isSftpEnabled: enableSftp
    largeFileSharesState: (storageAccountSku == 'Standard_LRS') || (storageAccountSku == 'Standard_ZRS')
      ? largeFileSharesState
      : null
    minimumTlsVersion: storageAccountMinimumTlsVersion
    supportsHttpsTrafficOnly: true
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
  }, hnsPropertyObject)
}

@description('Upsert the diagnostic settings for the storage account based on the given parameters.')
resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: storageAccount
  properties: {
    workspaceId: empty(logAnalyticsWorkspaceResourceId) ? '' : logAnalyticsWorkspaceResourceId
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Output the resource name for this storage account.')
output storageAccountName string = storageAccount.name
@description('Output the resource id of this storage account.')
output storageAccountResourceId string = storageAccount.id
@description('Output the primary endpoint for this storage account.')
output storageAccountPrimaryEndpoint object = storageAccount.properties.primaryEndpoints
@description('Output the API Version for this storage account.')
output storageAccountApiVersion string = storageAccount.apiVersion
