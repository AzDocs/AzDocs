// Parameters
@description('Specifies the name of the Log Analytics workspace.')
@minLength(4)
@maxLength(63)
param logAnalyticsWorkspaceName string

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
@minValue(-1)
@maxValue(730)
param retentionInDays int = 60

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the Log Analytics Workspace with the given parameters.')
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  tags: tags
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
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
