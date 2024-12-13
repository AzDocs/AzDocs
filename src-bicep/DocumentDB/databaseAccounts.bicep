/*
.SYNOPSIS
Creating a document db account with the given specs.
.DESCRIPTION
This module creates a document db account with the given specs.
.EXAMPLE
<pre>
module documentDb 'br:contosoregistry.azurecr.io/documentdb/databaseaccounts:latest' = {
  name: 'Creating_a_document_db_account'
  scope: resourceGroup
  params: {
    documentDbName: 'MyFirstDocumentDb'
    locations: [
      {
        locationName: 'westeurope'
        isZoneRedundant: false
      }
    ]
    subnetsToWhitelist: [
      {
        resourceGroupName: 'MyFirstResourceGroup'
        vnetName: 'MyFirstVnet'
        subnetName: 'MyFirstSubnet'
      }
    ]
    logAnalyticsWorkspaceResourceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/MyFirstResourceGroup/providers/Microsoft.OperationalInsights/workspaces/MyFirstLogAnalyticsWorkspace'
    tags: {
      environment: 'dev'
    }
  }
}
</pre>
<p>Creates a documentdb with the given specs</p>
.LINKS
- [Bicep Microsoft.DocumentDB databaseAccounts](https://learn.microsoft.com/en-us/azure/templates/microsoft.documentdb/databaseaccounts)
*/

@minLength(3)
@maxLength(44)
@description('The name of the DocumentDB account.')
param documentDbName string

@description('The location of the DocumentDB account. Defaults to the resourcegroups location.')
param location string = resourceGroup().location

@description('The locations for the DocumentDB account. Defaults to one location (westeurope) without zone redundancy.')
param locations array = [
  {
    locationName: 'westeurope'
    isZoneRedundant: false
  }
]

@allowed([
  'GlobalDocumentDB'
  'MongoDB'
  'Parse'
])
@description('The kind of the DocumentDB account. Defaults to GlobalDocumentDB.')
param documentDbKind string = 'GlobalDocumentDB'

@description('The backup policy for this DocumentDB. Defaults to continuous backup for 7 days.')
param backupPolicy object = {
  type: 'Continuous'
  continuousModeProperties: {
    tier: 'Continuous7Days'
  }
}

@description('The consistency policy for this DocumentDB. Defaults to Session.')
param consistencyPolicy object = {
  defaultConsistencyLevel: 'Session'
  maxIntervalInSeconds: 5
  maxStalenessPrefix: 100
}

@description('The identity for this DocumentDB. Defaults to SystemAssigned.')
param identity object = {
  type: 'SystemAssigned'
}

@description('''
The IPs to whitelist for this DocumentDB. Defaults to empty.
Make sure to pass an array of objects with the following properties:
- ipAddressOrRange: The CIDR notation for the IP to whitelist (you are allowed to omit the suffix if its a /32.). Examples: 123.123.123.123 or 123.123.123.123/24
''')
param ipsToWhitelist array = []

@description('''
The subnets to whitelist for this DocumentDB. Defaults to empty.
Make sure to pass an array of objects with the following properties:
- resourceGroupName: The name of the resourcegroup the vnet is in.
- vnetName: The name of the vnet.
- subnetName: The name of the subnet.
- subscriptionId: The subscription id of the vnet. (optional)
''')
param subnetsToWhitelist Subnet[] = []

type Subnet = {
  resourceGroupName: string
  vnetName: string
  subnetName: string
  subscriptionId: string?
}

@allowed([
  'Tls'
  'Tls11'
  'Tls12'
])
param minimalTlsVersion string = 'Tls12'

@description('The resource id of the Log Analytics workspace to send diagnostics data to.')
param logAnalyticsWorkspaceResourceId string

@description('''
    The tag object.
    For example (in YAML):
      ApplicationID: 1234
      ApplicationName: MyCmdbAppName
      ApplicationOwner: myproductowner@company.com
      AppTechOwner: myteam@company.com
      BillingIdentifier: 123456
      BusinessUnit: MyBusinessUnit
      CostType: Application
      EnvironmentType: dev
      PipelineBuildNumber: 2022.08.02-main
      PipelineRunUrl: https://dev.azure.com/org/TeamProject/_build/results?buildId=1234&view=results
''')
param tags object = {}

@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Enabled'

@description('The capacity for the DocumentDB account. Defaults to totallimit 1000 RU/s.')
param totalThroughputLimit int = 1000

@description('Enable free tier for the DocumentDB account. Defaults to false.')
param enableFreeTier bool = false

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [the docs](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings).')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

var virtualNetworkRules = [
  for subnet in subnetsToWhitelist: {
    id: '/subscriptions/${subnet.?subscriptionId ?? subscription().subscriptionId}/resourceGroups/${subnet.resourceGroupName}/providers/Microsoft.Network/virtualNetworks/${subnet.vnetName}/subnets/${subnet.subnetName}'
  }
]

@description('Upserting the DocumentDB account.')
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: documentDbName
  kind: documentDbKind
  location: location
  tags: tags
  identity: identity
  properties: {
    databaseAccountOfferType: 'Standard' // only Standard exists?
    consistencyPolicy: consistencyPolicy
    locations: locations
    virtualNetworkRules: virtualNetworkRules
    isVirtualNetworkFilterEnabled: true // Enable ACL's
    backupPolicy: backupPolicy
    minimalTlsVersion: minimalTlsVersion
    publicNetworkAccess: publicNetworkAccess
    enableFreeTier: enableFreeTier
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
    ipRules: ipsToWhitelist
    disableLocalAuth: true
  }
}

@description('Upsert the diagnostics for this keyvault.')
resource databaseAccountDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: databaseAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('Outputting the documentendpoint of the DocumentDB account.')
output documentEndpoint string = databaseAccount.properties.documentEndpoint
@description('Outputting the primary connectionstring of the DocumentDB account.')
output primaryConnectionString string = databaseAccount.listConnectionStrings().connectionStrings[0].connectionString
