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
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| managedEnvironmentZoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Whether or not this Managed Environment is zone-redundant. If this is true, you must set the vnetConfiguration object. |
| vnetConfigurationInternal | bool | <input type="checkbox"> | None | <pre>false</pre> | Depending on your virtual IP configuration, you can control whether your container app environment allows public ingress or ingress only from within your VNet.<br>You must provide a infrastructureSubnetId if the value is set to true.<br>When true, the endpoint of the environment is an internal load balancer, when false: the hosted apps are exposed on an internet-accessible public IP address. |
| containerInfraSubnetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | When vnetConfigurationInternal is true, it specifies the resource id of the subnet for Infrastructure components for the Container App.<br>This subnet must be in the same Vnet as the subnet defined in runtimeSubnetId when defined. It must be pre-existing. |
| appLogsConfigurationDestination | string | <input type="checkbox"> | None | <pre>'azure-monitor'</pre> | Cluster configuration which enables the log daemon to export app logs to a destination.<br>If 'log-analytics' is the value, you should provide valid values for the logAnalyticsConfiguration object for customerId and SharedKey.<br>Example:<br>&nbsp;&nbsp;'log-analytics' |
| daprAIInstrumentationKey | string | <input type="checkbox"> | None | <pre>''</pre> | The Instrumentation key for the AppInsights workspace.<br>Example:<br>applicationInsights.properties.InstrumentationKey |
| daprAIConnectionString | string | <input type="checkbox"> | None | <pre>''</pre> | The Instrumentation key for the AppInsights workspace.<br>Example:<br>applicationInsights.properties.InstrumentationKey |
| logAnalyticsConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | Configuration for logging in a Log Analytics workspace.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;customerId: logAnalyticsWorkspace.properties.customerId<br>&nbsp;&nbsp;&nbsp;sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey<br>} |
| workloadProfiles | array | <input type="checkbox"> | None | <pre>[]</pre> | Workload profiles configured for the Managed Environment for workloads to run on.<br>If you create an empty array, a Consumption plan will be used, else a Consumption + Dedicated plan will be used and the workflow profile is enabled.<br>A dedicated workload profile supports user defined routes (UDR), egress through NAT Gateway, and creating private endpoints on the container app environment. The minimum required subnet size is /27.<br>A consumption profile does not support user defined routes (UDR), egress through NAT Gateway, peering through a remote gateway, or other custom egress. The minimum required subnet size is /23.<br>You can create more workload profile later on.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Consumption'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;workloadProfileType: 'Consumption'<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Dedicated-D4'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;workloadProfileType: 'D4'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MinimumCount: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;MaximumCount: 2<br>&nbsp;&nbsp;&nbsp;}<br>] |
| infrastructureResourceGroupName | string | <input type="checkbox"> | None | <pre>take('MC_ME_&#36;{managedEnvironmentName}', 61)</pre> | Possibility to provide custom resourcegroup for the infrastructure resources of the managed environment.<br>Should not pre-exist or deployment will fail.<br>If not provided, the resourcegroup will be named: ME_<managedEnvironmentName>_<containerAppsName>_<locationName>, eg. ME_my-environment_my-container-apps_westeurope. |
| dockerBridgeCidr | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. CIDR notation IP range assigned to the Docker bridge network. <br>It must not overlap with any other provided IP ranges and can only be used when the environment is deployed into a virtual network. <br>If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.<br>Example:<br>'100.64.0.0/16' |
| platformReservedCidr | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. IP range in CIDR notation that can be reserved for environment infrastructure IP addresses. <br>It must not overlap with any other provided IP ranges and can only be used when the environment is deployed into a virtual network.<br>If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.<br>Example:<br>'100.65.0.0/16' |
| platformReservedDnsIP | string | <input type="checkbox"> | None | <pre>''</pre> | Conditional. An IP address from the IP range defined by "platformReservedCidr" that will be reserved for the internal DNS server. <br>It must not be the first address in the range and can only be used when the environment is deployed into a virtual network. <br>If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.<br>Example:<br>'100.65.0.10' |
| certificatePassword | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Password of the certificate used by the custom domain. |
| certificateValue | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Certificate to use for the custom domain. PFX or PEM. |
| dnsSuffix | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. DNS suffix for the environment domain. |
| peerTrafficEncryption | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Whether or not to encrypt peer traffic. |
| peerAuthenticationEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Peer authentication settings for the Managed Environment. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| managedEnvironmentResourceId | string | Output of the resource id of the management environment |
| managedEnvironmentName | string | Output of the name of the management environment |
| privateDnsZoneName | string | Output the private DNS zone of the management environment |
| managedEnvironmentStaticIp | string | Output the static IP of the management environment |

## Examples
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'cae')
  params: {
    managedEnvironmentName: cae-me-dev
    location: location
  }
}
</pre>
<p>Creates a container App managed environment with the name 'cae-me-dev' with the 'Consumption only' Environment Type, not Vnet integrated.</p>
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 52), 'cae')
  params: {
    managedEnvironmentName: managedEnvironmentName
    location: location
    vnetConfigurationInternal: true
    workloadProfiles: [
      {
        name: 'Dedicated-D4'
        workloadProfileType: 'D4'
        MinimumCount: 1
        MaximumCount: 2
      }
    ]
    containerInfraSubnetResourceId: '/subscriptions/aab80d35-e4a6-4c34-9c93-57a78545c8zz/resourceGroups/platform-dev/providers/Microsoft.Network/virtualNetworks/vnet-mysub-dev/subnets/snet-cae-dev'
  }
}
</pre>
<p>Creates an internal container App managed environment with the name managedEnvironmentName in your own subnet.</p>

## Links
- [Bicep Microsoft.App managedEnvironments](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep)
