/*
.SYNOPSIS
Creating a data collection endpoint.
.DESCRIPTION
Creating a data collection endpoint (DCE). A data collection endpoint (DCE) is a connection where data sources send collected data for processing and ingestion into Azure Monitor.
DCE is as a connector between the endpoint and Azure Log Ingestion Pipeline. DCE is required in 2 occasions: 1) You need network isolation, 2) You are sending data to custom logs in Azure LogAnalytics.
.NOTE
By default, the Microsoft.Insights resource provider isnt registered in a Subscription. Ensure to register it successfully before trying to create a Data Collection Endpoint.
.EXAMPLE
<pre>
module dcendpoint 'br:contosoregistry.azurecr.io/insights/datacollectionendpoints:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'dce')
  params: {
    dataCollectionEndpointName: 'dcename'
  }
}
</pre>
<p>Creates a data collection endpoint in Azure Monitor.</p>
.LINKS
- [Bicep Data Collection Endpoints](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionendpoints?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The location for this resource to be upserted in.')
param location string = resourceGroup().location

@description('The name of the data collection endpoint.')
param dataCollectionEndpointName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The identity type. This can be either `None`, a `System Assigned` or a `UserAssigned` identity. In the case of UserAssigned, the userAssignedIdentities must be set with the ResourceId of the user assigned identity resource and the identity must have at least read logs rbac rights on the resource in scope.')
@discriminator('type')
type identityType =
  | { type: 'None' }
  | { type: 'SystemAssigned' }
  | { type: 'UserAssigned', userAssignedIdentities: object }

@description('''
Sets the identity. This can be either `None`, a `System Assigned` or a `UserAssigned` identity.
Defaults no identity.
If type is `UserAssigned`, then userAssignedIdentities must be set with the ResourceId of the user assigned identity resource
and the identity must have at least read logs rbac rights on the resource in scope.
<details>
  <summary>Click to show example</summary>
<pre>
{
  type: 'UserAssigned'
  userAssignedIdentities: userAssignedIdentityId :{}
},
{
  type: 'SystemAssigned'
},
{
  type: 'None'
}
</pre>
</details>
''')
param identity identityType = {
  type: 'None'
}

@description('The data collection endpoint description.')
param dataCollectionEndpointDescription string = 'Data Collection Endpoint'

@description('The configuration to set whether network access from public internet to the endpoints is allowed. You can use Azure Monitor Private Link Scopes to restrict access to the endpoint (SecureByPerimeter).')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Enabled'

// ================================================= Resources ==================================================
resource datacollectionendpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: dataCollectionEndpointName
  location: location
  tags: tags
  identity: identity
  properties: {
    description: dataCollectionEndpointDescription
    networkAcls: {
      publicNetworkAccess: publicNetworkAccess
    }
  }
}

// ================================================= Outputs ====================================================
@description('The logs ingestion URI for the DataCollectionRule.')
output dataCollectionEndpointUri string = datacollectionendpoint.properties.logsIngestion.endpoint
@description('The immutableId property of the DCE object')
output dataCollectionEndpointImmutableId string = datacollectionendpoint.properties.immutableId
@description('The configurationAccess property of the DCE object')
output dataCollectionEndpointConfigurationAccess string = datacollectionendpoint.properties.configurationAccess.endpoint
@description('The metricsIngestion property of the DCE object')
output dataCollectionEndpointMetricsIngestion string = datacollectionendpoint.properties.metricsIngestion.endpoint
@description('The DCE resourceId.')
output dataCollectionEndpointId string = datacollectionendpoint.id
