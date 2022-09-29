/*
.SYNOPSIS
Creating a Container App Environment.
.DESCRIPTION
Creating a managed Container App Environment for a container app.
If you want to create public container apps the vnetconfiguration internal property should be set to false.
If you want to create private container apps the vnetconfiguration internal property should be set to true
.EXAMPLE
<pre>
module managedEnvironment '../../AzDocs/src-bicep/App/managedEnvironments.bicep' = {
  name: managedEnvironmentName
  params: {
    managedEnvironmentName: managedEnvironmentName
    location: location
    daprAIInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    logAnalyticsConfiguration: {
      customerId: LAW.outputs.logAnalyticsWorkspaceCustomerId
      sharedKey: LAW.outputs.logAnalyticsWorkspacePrimaryKey
    }
    vnetConfiguration: {
      dockerBridgeCidr: '10.3.0.1/16'
      infrastructureSubnetId: containerInfraSubnetResourceId
      internal: true
      platformReservedCidr: '10.2.0.0/16'
      platformReservedDnsIP: '10.2.0.2'
      runtimeSubnetId: containerSubnetResourceId
    }
  }
}
</pre>
<p>Creates a container App managed environment with the name managedEnvironmentName</p>
.LINKS
- [Bicep Microsoft.App managedEnvironments](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The name for the managed Environment for the Container App.')
@minLength(2)
@maxLength(260)
param managedEnvironmentName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Whether or not this Managed Environment is zone-redundant. If this is true, you must set the vnetConfiguration object.')
param managedEnvironmentZoneRedundant bool = false

@description('''
Boolean indicating if the environment only has an internal load balancer and does not have a public static IP resource.
You must provide infrastructureSubnetId if the value is set to true.
When true, the endpoint is an internal load balancer, when false: the hosted apps are exposed on an internet-accessible IP address
''')
param vnetConfigurationInternal bool = false

@description('''
When vnetConfigurationInternal is true, it specifies the resource id of the subnet for Infrastructure components for the Container App.
This subnet must be in the same Vnet as the subnet defined in runtimeSubnetId when defined. It must be pre-existing.
''')
param containerInfraSubnetResourceId string = ''

@description('''
Vnet configuration for the managed environment. If Zone Redundancy is true or (vnetConfiguration)Internal is true, this must be filled.
See for more information https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep#vnetconfiguration
Example:
{
  dockerBridgeCidr: '10.3.0.1/16'
  infrastructureSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, infraSubnetName)
  internal: true
  platformReservedCidr: '10.2.0.0/16'
  platformReservedDnsIP: '10.2.0.2'
  runtimeSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, runtimeSubnetName)
}
''')
param vnetConfiguration object = {
  infrastructureSubnetId: vnetConfigurationInternal ? containerInfraSubnetResourceId : ''
  internal: vnetConfigurationInternal
}

@description('''
Cluster configuration which enables the log daemon to export app logs to a destination.
Currently only "log-analytics" is supported.
If 'log-analytics' is the value, you should provide valid values for the logAnalyticsConfiguration object for customerId and SharedKey.
''')
@allowed([
  'log-analytics'
  ''
])
param appLogsConfigurationDestination string = ''

@description('''
The Instrumentation key for the AppInsights workspace.
Example:
applicationInsights.properties.InstrumentationKey
''')
param daprAIInstrumentationKey string = ''

@description('''Configuration for logging in a Log Analytics workspace.
Example:
{
  customerId: logAnalyticsWorkspace.properties.customerId
  sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
}
''')
param logAnalyticsConfiguration object = {}

resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: managedEnvironmentName
  location: location
  tags: tags
  properties: {
    daprAIInstrumentationKey: daprAIInstrumentationKey
    appLogsConfiguration: {
      destination: appLogsConfigurationDestination
      logAnalyticsConfiguration: logAnalyticsConfiguration
    }
    vnetConfiguration: vnetConfiguration
    zoneRedundant: managedEnvironmentZoneRedundant
  }
}

@description('Output of the resource id of the management environment')
output managedEnvironmentResourceId string = managedEnvironment.id
@description('Output of the name of the management environment')
output managedEnvironmentName string = managedEnvironment.name
