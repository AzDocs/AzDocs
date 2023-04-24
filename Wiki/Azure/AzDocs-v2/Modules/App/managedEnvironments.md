# managedEnvironments

Target Scope: resourceGroup

## Synopsis
Creating a Container App Environment.

## Description
Creating a managed Container App Environment for a container app.<br>
If you want to create public container apps the vnetconfiguration internal property should be set to false.<br>
If you want to create private container apps the vnetconfiguration internal property should be set to true

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| managedEnvironmentName | string | <input type="checkbox"> | Length between 2-260 | <pre>'cae-&#36;{uniqueString(resourceGroup().id)}'</pre> | The name for the managed Environment for the Container App. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| managedEnvironmentZoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether or not this Managed Environment is zone-redundant. If this is true, you must set the vnetConfiguration object. |
| vnetConfigurationInternal | bool | <input type="checkbox"> | None | <pre>false</pre> | Boolean indicating if the environment only has an internal load balancer and does not have a public static IP resource.<br>You must provide infrastructureSubnetId if the value is set to true.<br>When true, the endpoint is an internal load balancer, when false: the hosted apps are exposed on an internet-accessible IP address |
| containerInfraSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | When vnetConfigurationInternal is true, it specifies the resource id of the subnet for Infrastructure components for the Container App.<br>This subnet must be in the same Vnet as the subnet defined in runtimeSubnetId when defined. It must be pre-existing. |
| vnetConfiguration | object | <input type="checkbox"> | None | <pre>{<br>  infrastructureSubnetId: vnetConfigurationInternal ? containerInfraSubnetResourceId : ''<br>  internal: vnetConfigurationInternal<br>}</pre> | Vnet configuration for the managed environment. If Zone Redundancy is true or (vnetConfiguration)Internal is true, this must be filled.<br>See for more information https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep#vnetconfiguration<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;dockerBridgeCidr: '10.3.0.1/16'<br>&nbsp;&nbsp;&nbsp;infrastructureSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, infraSubnetName)<br>&nbsp;&nbsp;&nbsp;internal: true<br>&nbsp;&nbsp;&nbsp;platformReservedCidr: '10.2.0.0/16'<br>&nbsp;&nbsp;&nbsp;platformReservedDnsIP: '10.2.0.2'<br>&nbsp;&nbsp;&nbsp;runtimeSubnetId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, runtimeSubnetName)<br>} |
| appLogsConfigurationDestination | string | <input type="checkbox"> | None | <pre>''</pre> | Cluster configuration which enables the log daemon to export app logs to a destination.<br>If 'log-analytics' is the value, you should provide valid values for the logAnalyticsConfiguration object for customerId and SharedKey.<br>Example:<br>&nbsp;&nbsp;'log-analytics' |
| daprAIInstrumentationKey | string | <input type="checkbox"> | None | <pre>''</pre> | The Instrumentation key for the AppInsights workspace.<br>Example:<br>applicationInsights.properties.InstrumentationKey |
| daprAIConnectionString | string | <input type="checkbox"> | None | <pre>''</pre> | The Instrumentation key for the AppInsights workspace.<br>Example:<br>applicationInsights.properties.InstrumentationKey |
| logAnalyticsConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | Configuration for logging in a Log Analytics workspace.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;customerId: logAnalyticsWorkspace.properties.customerId<br>&nbsp;&nbsp;&nbsp;sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey<br>} |
| workloadProfiles | array | <input type="checkbox"> | None | <pre>[]</pre> | Workload profiles configured for the Managed Environment for workloads to run on.<br>If you create an empty array, a Consumption plan will be used, else a Consumption + Dedicated plan will be used and the workflow profile is enabled.<br>You can create more workload profile later on.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Consumption'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;workloadProfileType: 'Consumption'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Dedicated-D4'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;workloadProfileType: 'D4'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MinimumCount: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MaximumCount: 2<br>&nbsp;&nbsp;&nbsp;}<br>] |
| infrastructureResourceGroup | string | <input type="checkbox"> | None | <pre>'MC_ME_&#36;{managedEnvironmentName}'</pre> | Possibility to provide custom resourcegroup for the infrastructure resources of the managed environment.<br>Should not pre-exist or deployment will fail.<br>If not provided, the resourcegroup will be named: ME_<managedEnvironmentName>_<containerAppsName>_<locationName>, eg. ME_my-environment_my-container-apps_westeurope. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| managedEnvironmentResourceId | string | Output of the resource id of the management environment |
| managedEnvironmentName | string | Output of the name of the management environment |
## Examples
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
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

## Links
- [Bicep Microsoft.App managedEnvironments](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep)


