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
@minLength(0)
param logAnalyticsWorkspaceResourceId string

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

@description('Build the needed object for the virtualNetworkRules based on the `subnetIdsToWhitelist` parameter.')
var virtualNetworkRules = [for subnetId in subnetIdsToWhitelist: {
  id: subnetId
  action: 'Allow'
}]

@description('Build the needed object for the virtualNetworkRules based on the `publicIpsToWhitelist` parameter.')
var ipRules = [for ip in publicIpsToWhitelist: {
  action: 'Allow'
  value: ip
}]

@description('Setting up the networkAcls and add rules if any are defined.')
var networkAcls = empty(virtualNetworkRules) && empty(ipRules) ? {
  defaultAction: 'Allow'
} : {
  defaultAction: 'Deny'
  virtualNetworkRules: virtualNetworkRules
  ipRules: ipRules
}

@description('Upsert the storage account based on the given parameters.')
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: toLower(storageAccountName)
  location: location
  kind: storageAccountKind
  tags: tags
  sku: {
    name: storageAccountSku
  }
  properties: {
    accessTier: defaultBlobAccessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    minimumTlsVersion: storageAccountMinimumTlsVersion
    supportsHttpsTrafficOnly: true
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
  }
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
@description('The Storage Account keys (outputing this so it can be used when creating function apps).')
output storageAccountKey string = storageAccount.listKeys().keys[0].value
