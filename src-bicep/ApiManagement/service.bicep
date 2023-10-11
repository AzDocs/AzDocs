/*
.SYNOPSIS
Creating an Api Management Service.
.DESCRIPTION
Creating an Api Management Service.
<pre>
module apim 'br:contosoregistry.azurecr.io/apimanagement/service.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 59), 'apim')
  params: {
    location: location
    apiManagementServiceName: 'myapim'
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
    publisherEmail: 'noreply@mail.com'
    publisherName: 'Publisher Name'
    virtualNetworkConfiguration: {
      subnetResourceId: '${subscription().id}/resourceGroups/${virtualNetworkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${apimSubnetName}'
    }
    virtualNetworkType: 'Internal'
    publicIpAddressName: 'apimPublicIP'
  }
}
</pre>
<p>Creates an apim service with the name apimservicename that is integrated in the virtualNetworkName Vnet.</p>
.LINKS
- [Bicep Microsoft.ApiManagement service](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('Specifies the Azure location where the key vault should be created.')
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

@description('The name of the API Management service instance.')
param apiManagementServiceName string

@description('The email address of the owner/administrator of the API Management service instance. This should be a valid notation for an email address.')
@minLength(3)
param publisherEmail string

@description('The name of the owner of the API Management service instance. This can be the name of your organization for use in the developer portal and e-mail notifications.')
@minLength(1)
param publisherName string

@description('The email address from which the notification will be sent. This should be a valid notation for an email address.')
param notificationSenderEmail string = ''

@description('The pricing tier of this API Management service instance.')
@allowed([
  'Basic'
  'Consumption'
  'Developer'
  'Premium'
  'Standard'
])
param sku string = 'Developer'

@description('The instance size of this API Management service instance. Capacity of the SKU (number of deployed units of the SKU). For Consumption SKU capacity must be specified as 0.')
@minValue(0)
param skuCount int = 1

@description('The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled.')
@minLength(0)
param logAnalyticsWorkspaceResourceId string = ''

@description('The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`.')
@minLength(1)
@maxLength(260)
param diagnosticsName string = 'AzurePlatformCentralizedLogging'

@description('Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [the documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings)')
param diagnosticSettingsMetricsCategories array = [
  {
    categoryGroup: 'AllMetrics'
    enabled: true
  }
]

@description('Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings).')
param diagnosticSettingsLogsCategories array = [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
]

@description('''
Sets the identity property of the Api Management Service. This can be either both a System Assigned and User Assigned identity.
If type is `UserAssigned`, then userAssignedIdentities must be set with the ResourceId of the user assigned identity resource.
<details>
  <summary>Click to show example</summary>
<pre>
{
  type: 'UserAssigned'
  userAssignedIdentities: {}
},
{
  type: 'SystemAssigned'
},
{
  type: 'SystemAssigned, UserAssigned'
  userAssignedIdentities: userAssignedIdentityId
}
</pre>
</details>
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('''
The API version constraint for the management service. Limit control plane API calls to API Management service with version equal to or newer than this value.
Examples:
'2019-12-01'
''')
param apiVersionConstraintMinApiVersion string = '2019-12-01'

@description('Whether or not public endpoint access is allowed for this API Management service. Value is optional but if passed in, must be \'Enabled\' or \'Disabled\'. If \'Disabled\', private endpoints are the exclusive access method. Default value is \'Enabled\'')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Virtual network name for the virtual network integration of the Apim resource.')
param virtualNetworkName string = ''

@description('The name of the subnet to use for the virtual network integration of the Apim resource.')
param virtualNetworkIntegrationSubnetName string = ''

@description('The resourcegroup name of the virtual network to use for the virtual network integration of the Apim resource.')
param virtualNetworkResourceGroupName string = ''

@description('''
The virtual network configuration of this API Management service. If you set this by setting values for virtualNetworkName, virtualNetworkResourceGroupName and virtualNetworkIntegrationSubnetName,
you need to set virtualNetworkType either to External or Internal.
You also need to open NSG ports [docs](https://learn.microsoft.com/en-gb/azure/api-management/virtual-network-reference?tabs=stv2)
and other configuration [docs](https://learn.microsoft.com/en-us/azure/api-management/api-management-using-with-internal-vnet?source=recommendations&tabs=stv2)
''')
var virtualNetworkConfiguration = empty(virtualNetworkName) ? {} : {
  subnetResourceId: '${subscription().id}/resourceGroups/${virtualNetworkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${virtualNetworkIntegrationSubnetName}'
}

@description('''
Type of network. None (Default Value) means the API Management service is not part of any Virtual Network. This is mandatory when using private endpoints.
External means the API Management deployment is set up inside a Virtual Network having an Internet Facing Endpoint.
Internal means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.
For Internal and External you can use a public ip in the configuration. This must have a Fully qualified domain name of the A DNS record associated with the public IP. See[docs](aka.ms/azurestandardpublicip)
''')
@allowed([
  'External'
  'Internal'
  'None'
])
param virtualNetworkType string = 'None'

@description('A list of availability zones denoting where the resource needs to come from. Currently you need to use the Premium sku for this. Set the right sku capacity as well.')
@allowed([
  '1'
  '2'
  '3'
])
param zones array = []

@description('''
A list of CA certificates (root or intermediates) that are to be installed on the API Management service instance.
<details>
  <summary>Click to show example</summary>
[
  {
    encodedCertificate: loadTextContent('./pfx_converted_to_Base-64_encoded_string.txt')
    certificatePassword: 'mydummypassword'
    storeName: 'Root'
  }
]
</details>
''')
param certificates array = []

param publicIpAddressName string = ''

@description('ResourceGroup Name that can be used if the Public IP is in a different resource group. Otherwise it defaults the current resource group.')
param publicIpAddressResourceGroupName string = az.resourceGroup().name

param privateEndpointVirtualNetworkName string = ''

@description('Boolean to undelete Api Management Service if it was previously soft-deleted. If this flag is specified and set to True all other properties will be ignored.')
param apiManagementServiceRestore bool = false

@description('The name of the Private endpoint to use for the API Management instance. If you fill this, a private endpoint will be created.')
param privateEndpointName string = ''

@description('The name of the subnet to use for the private endpoint.')
param privateEndpointSubnetName string = ''

@description('The name of the resource group containing the private DNS zone for the private endpoint.')
param privateDnsZoneResourceGroupName string = az.resourceGroup().name

@description('''
Custom properties of the API Management service for setting enhanced security settings.
See [docs](https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Ciphers/)
<details>
  <summary>Click to show example</summary>
<pre>
{
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'False'
  'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'False'
}
</pre>
</details>
''')
param customProperties object = {}

@description('Property that can be used to enable NAT Gateway for this API Management service.')
@allowed([
  'Enabled'
  'Disabled'
])
param natGatewayState string = 'Disabled'

@description('''
The custom domains configuration for this APIM instance. An array per custom domain consisting of type, hostname, certificate store amongst others.
Default you will have the builtin Gateway endpoint with hostname <your apim instancename>.azure-api.net
See [docs](https://learn.microsoft.com/en-us/azure/api-management/configure-custom-domain?tabs=custom).
''')
param hostnameConfigurations array = []

@description('The name of the private DNS zone for the private endpoint. This needs to be pre-existing.')
var privateDNSZoneName = 'privatelink.azure-api.net'

// ================================================= Resources =================================================
@description('Possibly fetch the Public IP used for the Apim instance if integration in a VNET is used.')
resource apimVnetPublicIp 'Microsoft.Network/publicIPAddresses@2023-05-01' existing = if (!empty(publicIpAddressName)) {
  name: publicIpAddressName
  scope: resourceGroup(publicIpAddressResourceGroupName)
}

resource privateEndpointVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' existing = if (!empty(privateEndpointVirtualNetworkName)) {
  name: privateEndpointVirtualNetworkName
  scope: resourceGroup(virtualNetworkResourceGroupName)
}

@description('The API Management service instance. It can take between 30 and 40 minutes to create and activate an API Management service.')
resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' = {
  name: apiManagementServiceName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: skuCount
  }
  identity: identity
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: notificationSenderEmail
    hostnameConfigurations: hostnameConfigurations
    apiVersionConstraint: {
      minApiVersion: apiVersionConstraintMinApiVersion
    }
    publicNetworkAccess: publicNetworkAccess
    virtualNetworkConfiguration: empty(virtualNetworkConfiguration) ? null : virtualNetworkConfiguration
    publicIpAddressId: empty(publicIpAddressName) ? null : apimVnetPublicIp.id
    virtualNetworkType: virtualNetworkType
    certificates: certificates
    customProperties: empty(customProperties) ? null : customProperties
    restore: apiManagementServiceRestore
    natGatewayState: natGatewayState
  }
  zones: zones
}

@description('''
Creating a private endpoint for the API Management service, when private endpoint name is provided.
You cannot have both a private endpoint and a virtual network integration (internal or external).
Network policies such as network security groups must be disabled in the subnet used for the private endpoint.
''')
module privateEndpoint '../Network/privateEndpoints.bicep' = if (!empty(privateEndpointName)) {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'privateEndpoint')
  params: {
    privateDnsLinkName: apiManagementServiceName
    privateDnsZoneName: privateDNSZoneName
    privateEndpointGroupId: 'Gateway'
    subnetName: privateEndpointSubnetName
    targetResourceId: apiManagementService.id
    privateEndpointName: apiManagementServiceName
    virtualNetworkName: privateEndpointVirtualNetworkName
    virtualNetworkResourceId: privateEndpointVirtualNetwork.id
    location: location
    privateDnsZoneResourceGroupName: privateDnsZoneResourceGroupName
  }
}

@description('Upsert the diagnostics for this resource.')
resource apimDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceResourceId)) {
  name: diagnosticsName
  scope: apiManagementService
  properties: {
    workspaceId: logAnalyticsWorkspaceResourceId
    logs: diagnosticSettingsLogsCategories
    metrics: diagnosticSettingsMetricsCategories
  }
}

@description('The name of the created API Management service instance.')
output apiManagementServiceName string = apiManagementService.name
@description('The Resource Id of the created API Management service instance.')
output apiManagementServiceId string = apiManagementService.id
@description('The id of the system assigned principal attached to the API Management service instance.')
output apiManagementPrincipalId string = apiManagementService.identity.principalId
