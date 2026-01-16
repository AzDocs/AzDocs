/*
.SYNOPSIS
Creating a Container App Environment.
.DESCRIPTION
Creating a managed Container App Environment for a container app.
If you want to create public container apps, the vnetconfiguration internal property should be set to false.
If you want to create private container apps, the vnetconfiguration internal property should be set to true
.EXAMPLE
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'cae')
  params: {
    managedEnvironmentName: cae-me-dev
    location: location
    publicNetworkAccess: 'Enabled'
  }
}
</pre>
<p>Creates a public container App managed environment with the name 'cae-me-dev' with the 'Consumption only' Environment Type, not Vnet integrated.</p>
.EXAMPLE
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'cae')
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
.EXAMPLE
<pre>
module managedEnvironment 'br:contosoregistry.azurecr.io/app/managedenvironments:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'cae')
  params: {
    managedEnvironmentName: managedEnvironmentName
    location: location
    vnetConfigurationInternal: true
    certificatePassword: 'somethingsomething'
    dnsSuffix:'azure.org'
    certificateValue: loadFileAsBase64('testcertazure.org.pfx')
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
<p>Creates an internal container App managed environment with the name managedEnvironmentName in your own subnet with a private certificate.</p>
.LINKS
- [Bicep Microsoft.App managedEnvironments](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/2025-10-02-preview/managedenvironments?pivots=deployment-language-bicep)
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
param tags object?

@description('''
Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. 
For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).
Example:
identity: {
  type: 'None'
},
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}
  }
}
''')
param identity IdentityType = {
  type: 'SystemAssigned'
}

@discriminator('type')
type IdentityType =
  | {
    type: 'SystemAssigned'
  }
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('Whether or not this Managed Environment is zone-redundant. If this is true, you must set the vnetConfiguration object.')
param managedEnvironmentZoneRedundant bool = false

@description('''
Depending on your virtual IP configuration, you can control whether your container app environment allows public ingress or ingress only from within your VNet.
You must provide a infrastructureSubnetId if the value is set to true.
When true, the endpoint of the environment is an internal load balancer, when false: the hosted apps are exposed on an internet-accessible public IP address.
''')
param vnetConfigurationInternal bool = false

@description('''
When vnetConfigurationInternal is true, it specifies the resource id of the subnet for Infrastructure components for the Container App.
This subnet must be in the same Vnet as the subnet defined in runtimeSubnetId when defined. It must be pre-existing.
To be able to use a subnet smaller than /23 you need to configure a dedicated workload profile in workloadProfiles.
''')
param containerInfraSubnetResourceId string = ''

@description('''
Cluster configuration which enables the log daemon to export app logs to a destination.
If 'log-analytics' is the value, you should provide valid values for the logAnalyticsConfiguration object for customerId and SharedKey.
Example:
 'log-analytics'
''')
@allowed([
  'azure-monitor'
  'log-analytics'
  'none'
])
param appLogsConfigurationDestination string = 'azure-monitor'

@description('''
Application Insights connection string used by Dapr to export Service to Service communication telemetry.
Example:
applicationInsights.properties.ConnectionString
''')
@secure()
param daprAIConnectionString string = ''

@description('''
Configuration for logging in a Log Analytics workspace.
Example:
{
  customerId: logAnalyticsWorkspace.properties.customerId
  sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
}
''')
param logAnalyticsConfiguration object = {}

@description('''
Workload profiles configured for the Managed Environment for workloads to run on.
If you create an empty array, a Consumption plan will be used, else a Consumption and/or Dedicated plan will be used and the workflow profile is enabled.
A dedicated workload profile supports user defined routes (UDR), egress through NAT Gateway, and creating private endpoints on the container app environment. The minimum required subnet size is /27.
You can have a Consumption profile only in the Workload profile. When create a container app, you select the profile.
A consumption profile does not support user defined routes (UDR), egress through NAT Gateway, peering through a remote gateway, or other custom egress. The minimum required subnet size is /23.
You can create more workload profile later on.
Example:
[
  {
    name: 'Consumption'
    workloadProfileType: 'Consumption'
  }
  {
    name: 'Dedicated-D4'
    workloadProfileType: 'D4'
    MinimumCount: 1
    MaximumCount: 2
  }
]
''')
param workloadProfiles array = []

@description('''
Possibility to provide custom resourcegroup for the infrastructure resources of the managed environment.
Should not pre-exist or deployment will fail.
If not provided, the resourcegroup will be named: ME_<managedEnvironmentName>_<containerAppsName>_<locationName>, eg. ME_my-environment_my-container-apps_westeurope.
''')
param infrastructureResourceGroupName string = take('ME_${managedEnvironmentName}', 61)

@description('''
Conditional. CIDR notation IP range assigned to the Docker bridge network. 
It must not overlap with any other provided IP ranges and can only be used when the environment is deployed into a virtual network. 
If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.
Example:
'100.64.0.0/16'
''')
param dockerBridgeCidr string = ''

@description('''
Conditional. IP range in CIDR notation that can be reserved for environment infrastructure IP addresses. 
It must not overlap with any other provided IP ranges and can only be used when the environment is deployed into a virtual network.
If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.
Example:
'100.65.0.0/16'
 ''')
param platformReservedCidr string = ''

@description('''
Conditional. An IP address from the IP range defined by "platformReservedCidr" that will be reserved for the internal DNS server. 
It must not be the first address in the range and can only be used when the environment is deployed into a virtual network. 
If not provided, it will be set with a default value by the platform. Required if zoneRedundant is set to true to make the resource WAF compliant.
Example:
'100.65.0.10'
''')
param platformReservedDnsIP string = ''

@description('Optional. Password of the certificate used by the custom domain. Expected is a certificate in an Application Gateway instead.')
@secure()
param certificatePassword string = ''

@description('Optional. Certificate to use for the custom domain. PFX or PEM. Expected is a certificate in an Application Gateway instead.')
@secure()
param certificateValue string = ''

@description('Optional. DNS suffix for the environment domain.')
param dnsSuffix string = ''

@description('Optional. Whether or not to encrypt peer traffic.')
param peerTrafficEncryption bool = false

@description('Peer authentication settings for the Managed Environment.')
param peerAuthenticationEnabled bool = false

@description('Optional. Application Insights connection string for environment-level monitoring.')
@secure()
param appInsightsConnectionString string = ''

@description('''
Optional. Availability zones to use for the managed environment.
Example: ['1', '2', '3']
''')
param availabilityZones array = []

@description('Optional. Azure Monitor instrumentation key used by Dapr to export Service to Service communication telemetry.')
@secure()
param daprAIInstrumentationKey string = ''

@description('Optional. Property to allow or block all public traffic. Allowed Values: Enabled, Disabled.')
param publicNetworkAccess string = 'Disabled'

@description('Optional. Dynamic JSON columns setting for Log Analytics.')
param logAnalyticsDynamicJsonColumns bool = false

@description('''
Optional. Disk encryption configuration for the Managed Environment.
Example:
{
  keyVaultConfiguration: {
    auth: {
      identity: '/subscriptions/.../Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity'
    }
    keyUrl: 'https://myvault.vault.azure.net/keys/mykey/version'
  }
}
''')
param diskEncryptionConfiguration object = {}

@description('''
Optional. Ingress configuration for the Managed Environment.
Ingress cannot be deployed on Consumption or Flex workload profiles
Example:
{
  headerCountLimit: 100
  requestIdleTimeout: 4
  terminationGracePeriodSeconds: 480
  workloadProfileName: 'Dedicated-D4'
}
''')
param ingressConfiguration object = {}

@description('''
Optional. Environment Open Telemetry configuration.
Example:
{
  destinationsConfiguration: {
    otlpConfigurations: [
      {
        name: 'myOtlp'
        endpoint: 'https://otlp.example.com:4318'
        insecure: false
        headers: [{ key: 'api-key', value: 'secret' }]
      }
    ]
  }
  logsConfiguration: { destinations: ['otlp'] }
  metricsConfiguration: { destinations: ['otlp'], includeKeda: false }
  tracesConfiguration: { destinations: ['otlp'], includeDapr: false }
}
''')
param openTelemetryConfiguration object = {}

@description('Optional. Dapr configuration object. Use {} to enable with defaults. Example: {version: \'1.13.6-msft.6\' }.')
param daprConfiguration object = {}

@description('Optional. Keda configuration object. Use {} to enable with defaults. Example: {version: \'2.17.2\'} .')
param kedaConfiguration object = {}

@description('''
Optional. Certificate Key Vault properties for custom domain.
Example:
{
  identity: 'system' or '/subscriptions/.../Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity'
  keyVaultUrl: 'https://myvault.vault.azure.net/secrets/mycert'
}
''')
param certificateKeyVaultProperties object = {}


//================================================= Resources =================================================
resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-10-02-preview' = {
  name: managedEnvironmentName
  location: location
  identity: identity
  tags: tags
  properties: {
    appInsightsConfiguration: !empty(appInsightsConnectionString)
      ? {
          connectionString: appInsightsConnectionString
        }
      : null
    appLogsConfiguration: {
      destination: appLogsConfigurationDestination
      logAnalyticsConfiguration: (appLogsConfigurationDestination == 'log-analytics')
        ? union(logAnalyticsConfiguration, {
            dynamicJsonColumns: logAnalyticsDynamicJsonColumns
          })
        : null
    }
    availabilityZones: !empty(availabilityZones) ? availabilityZones : null
    customDomainConfiguration: (!empty(certificateValue) || !empty(certificateKeyVaultProperties) || !empty(dnsSuffix)) ? {
      certificatePassword: !empty(certificatePassword) ? certificatePassword : null
      certificateValue: !empty(certificateValue) ? certificateValue : null
      certificateKeyVaultProperties: !empty(certificateKeyVaultProperties) ? certificateKeyVaultProperties : null
      dnsSuffix: !empty(dnsSuffix) ? dnsSuffix : null
    } : null
    daprAIConnectionString: (!empty(daprAIConnectionString) && empty(appInsightsConnectionString)) ? daprAIConnectionString : null
    daprAIInstrumentationKey: !empty(daprAIInstrumentationKey) ? daprAIInstrumentationKey : null
    daprConfiguration: !empty(daprConfiguration) ? daprConfiguration : null
    diskEncryptionConfiguration: !empty(diskEncryptionConfiguration) ? diskEncryptionConfiguration : null
    infrastructureResourceGroup: infrastructureResourceGroupName
    ingressConfiguration: !empty(ingressConfiguration) ? ingressConfiguration : null
    kedaConfiguration: !empty(kedaConfiguration) ? kedaConfiguration : null
    openTelemetryConfiguration: !empty(openTelemetryConfiguration) ? openTelemetryConfiguration : null
    peerAuthentication: {
      mtls: {
        enabled: peerAuthenticationEnabled
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: peerTrafficEncryption
      }
    }
    publicNetworkAccess: publicNetworkAccess
    vnetConfiguration: (!empty(containerInfraSubnetResourceId) && vnetConfigurationInternal) ? {
      internal: vnetConfigurationInternal
      infrastructureSubnetId: !empty(containerInfraSubnetResourceId) ? containerInfraSubnetResourceId : null
      dockerBridgeCidr: !empty(containerInfraSubnetResourceId) ? dockerBridgeCidr : null
      platformReservedCidr: (empty(workloadProfiles) && !empty(containerInfraSubnetResourceId)) ? platformReservedCidr : null
      platformReservedDnsIP: (empty(workloadProfiles) && !empty(containerInfraSubnetResourceId)) ? platformReservedDnsIP : null
    } : null
    workloadProfiles: !empty(workloadProfiles) ? workloadProfiles : null
    zoneRedundant: !empty(availabilityZones) ? true : (!empty(containerInfraSubnetResourceId) ? managedEnvironmentZoneRedundant : false)
  }
}

// ================================================= Outputs =================================================
@description('Output of the resource id of the management environment')
output managedEnvironmentResourceId string = managedEnvironment.id

@description('Output of the name of the management environment')
output managedEnvironmentName string = managedEnvironment.name

@description('Output the private DNS zone of the management environment')
output privateDnsZoneName string = managedEnvironment.properties.defaultDomain

@description('Output the static IP of the management environment')
output managedEnvironmentStaticIp string = managedEnvironment.properties.staticIp
