/*
.SYNOPSIS
Creating a  a Log Analytics Workspace.
.DESCRIPTION
Creating a  a Log Analytics Workspace.
<pre>
module origin 'br:contosoregistry.azurecr.io/operationalinsights/workspaces.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'loganalytics')
  params: {
    logAnalyticsWorkspaceName: 'workspacename'
    location: location
    retentionInDays: 30
  }
}
</pre>
<p>Creates a Log Analytics Workspace with the name workspacename.</p>
.LINKS
- [Bicep Microsoft.OperationalInsights workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('Specifies the name of the Log Analytics workspace.')
@minLength(4)
@maxLength(63)
param logAnalyticsWorkspaceName string

@description('Specifies the service tier of the workspace')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param sku string = 'PerNode'

@description('Specifies the capacity reservation level for this workspace. This is only applicable when the Sku is CapacityReservation. Default value is -1 which means no capacity reservation.')
@allowed([
  -1
  0
  100
  200
  300
  400
  500
  1000
  2000
  5000
  10000
  25000
  50000
])
param capacityReservationLevel int = -1

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
@minValue(-1)
@maxValue(730)
param retentionInDays int = 60

@description('Flag that indicates if local auth should be disabled.')
param disableLocalAuth bool = true

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Specifies the public network access type for accessing Log Analytics ingestion.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Specifies the public network access type for accessing Log Analytics query.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Flag that indicates which permission to use - resource or workspace or both. True means: Use resource or workspace permissions.')
param enableLogAccessUsingOnlyResourcePermissions bool = true

@description('Flag that indicate if data should be exported.')
param enableDataExport bool = false

@description('Workspace capping daily quota in GB. -1 means unlimited.')
param workspaceCappingDailyQuotaGb int = -1

var unionedSku = union({
    name: sku
  },
  capacityReservationLevel == -1 ? {} : { capacityReservationLevel: capacityReservationLevel })

// ===================================== Resources =====================================
@description('Upsert the Log Analytics Workspace with the given parameters.')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  tags: tags
  location: location
  properties: {
    sku: unionedSku
    retentionInDays: retentionInDays
    features: {
      enableDataExport: enableDataExport
      enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
      disableLocalAuth: disableLocalAuth
    }
    workspaceCapping: {
      dailyQuotaGb: workspaceCappingDailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
  }
}

@description('Outputs the Log Analytics Workspace Resource ID.')
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.id
@description('Outputs the Log Analytics Workspace Resource Name.')
output logAnalyticsWorkspaceResourceName string = logAnalyticsWorkspace.name
@description('Outputs the Log Analytics Workspace Customer ID.')
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId
@description('Outputs the Log Analytics Workspace Primary Key.')
#disable-next-line outputs-should-not-contain-secrets
output logAnalyticsWorkspacePrimaryKey string = listKeys(logAnalyticsWorkspace.id, logAnalyticsWorkspace.apiVersion).primarySharedKey
