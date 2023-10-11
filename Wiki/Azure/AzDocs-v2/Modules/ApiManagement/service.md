# service

Target Scope: resourceGroup

## Synopsis
Creating an Api Management Service.

## Description
Creating an Api Management Service.<br>
<pre><br>
module apim 'br:contosoregistry.azurecr.io/apimanagement/service.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 59), 'apim')<br>
  params: {<br>
    location: location<br>
    apiManagementServiceName: 'myapim'<br>
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId<br>
    publisherEmail: 'noreply@mail.com'<br>
    publisherName: 'Publisher Name'<br>
    virtualNetworkConfiguration: {<br>
      subnetResourceId: '${subscription().id}/resourceGroups/${virtualNetworkResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}/subnets/${apimSubnetName}'<br>
    }<br>
    virtualNetworkType: 'Internal'<br>
    publicIpAddressName: 'apimPublicIP'<br>
  }<br>
}<br>
</pre><br>
<p>Creates an apim service with the name apimservicename that is integrated in the virtualNetworkName Vnet.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the key vault should be created. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the API Management service instance. |
| publisherEmail | string | <input type="checkbox" checked> | Length between 3-* | <pre></pre> | The email address of the owner/administrator of the API Management service instance. This should be a valid notation for an email address. |
| publisherName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the owner of the API Management service instance. This can be the name of your organization for use in the developer portal and e-mail notifications. |
| notificationSenderEmail | string | <input type="checkbox"> | None | <pre>''</pre> | The email address from which the notification will be sent. This should be a valid notation for an email address. |
| sku | string | <input type="checkbox"> | `'Basic'` or `'Consumption'` or `'Developer'` or `'Premium'` or `'Standard'` | <pre>'Developer'</pre> | The pricing tier of this API Management service instance. |
| skuCount | int | <input type="checkbox"> | Value between 0-* | <pre>1</pre> | The instance size of this API Management service instance. Capacity of the SKU (number of deployed units of the SKU). For Consumption SKU capacity must be specified as 0. |
| logAnalyticsWorkspaceResourceId | string | <input type="checkbox"> | Length between 0-* | <pre>''</pre> | The azure resource id of the log analytics workspace to log the diagnostics to. If you set this to an empty string, logging & diagnostics will be disabled. |
| diagnosticsName | string | <input type="checkbox"> | Length between 1-260 | <pre>'AzurePlatformCentralizedLogging'</pre> | The name of the diagnostics. This defaults to `AzurePlatformCentralizedLogging`. |
| diagnosticSettingsMetricsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'AllMetrics'<br>    enabled: true<br>  }<br>]</pre> | Which Metrics categories to enable; This defaults to `AllMetrics`. For array/object format, please refer to [the documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep&pivots=deployment-language-bicep#metricsettings) |
| diagnosticSettingsLogsCategories | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    categoryGroup: 'allLogs'<br>    enabled: true<br>  }<br>]</pre> | Which log categories to enable; This defaults to `allLogs`. For array/object format, please refer to [the documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep#logsettings). |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property of the Api Management Service. This can be either both a System Assigned and User Assigned identity.<br>If type is `UserAssigned`, then userAssignedIdentities must be set with the ResourceId of the user assigned identity resource.<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br><pre><br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: {}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned, UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: userAssignedIdentityId<br>}<br></pre><br></details> |
| apiVersionConstraintMinApiVersion | string | <input type="checkbox"> | None | <pre>'2019-12-01'</pre> | The API version constraint for the management service. Limit control plane API calls to API Management service with version equal to or newer than this value.<br>Examples:<br>'2019-12-01' |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Whether or not public endpoint access is allowed for this API Management service. Value is optional but if passed in, must be \'Enabled\' or \'Disabled\'. If \'Disabled\', private endpoints are the exclusive access method. Default value is \'Enabled\' |
| virtualNetworkName | string | <input type="checkbox"> | None | <pre>''</pre> | Virtual network name for the virtual network integration of the Apim resource. |
| virtualNetworkIntegrationSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the subnet to use for the virtual network integration of the Apim resource. |
| virtualNetworkResourceGroupName | string | <input type="checkbox"> | None | <pre>''</pre> | The resourcegroup name of the virtual network to use for the virtual network integration of the Apim resource. |
| virtualNetworkType | string | <input type="checkbox"> | `'External'` or `'Internal'` or `'None'` | <pre>'None'</pre> | Type of network. None (Default Value) means the API Management service is not part of any Virtual Network. This is mandatory when using private endpoints.<br>External means the API Management deployment is set up inside a Virtual Network having an Internet Facing Endpoint.<br>Internal means that API Management deployment is setup inside a Virtual Network having an Intranet Facing Endpoint only.<br>For Internal and External you can use a public ip in the configuration. This must have a Fully qualified domain name of the A DNS record associated with the public IP. See[docs](aka.ms/azurestandardpublicip) |
| zones | array | <input type="checkbox"> | `'1'` or `'2'` or `'3'` | <pre>[]</pre> | A list of availability zones denoting where the resource needs to come from. Currently you need to use the Premium sku for this. Set the right sku capacity as well. |
| certificates | array | <input type="checkbox"> | None | <pre>[]</pre> | A list of CA certificates (root or intermediates) that are to be installed on the API Management service instance.<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;encodedCertificate: loadTextContent('./pfx_converted_to_Base-64_encoded_string.txt')<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;certificatePassword: 'mydummypassword'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;storeName: 'Root'<br>&nbsp;&nbsp;&nbsp;}<br>]<br></details> |
| publicIpAddressName | string | <input type="checkbox"> | None | <pre>''</pre> |  |
| publicIpAddressResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | ResourceGroup Name that can be used if the Public IP is in a different resource group. Otherwise it defaults the current resource group. |
| privateEndpointVirtualNetworkName | string | <input type="checkbox"> | None | <pre>''</pre> |  |
| apiManagementServiceRestore | bool | <input type="checkbox"> | None | <pre>false</pre> | Boolean to undelete Api Management Service if it was previously soft-deleted. If this flag is specified and set to True all other properties will be ignored. |
| privateEndpointName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the Private endpoint to use for the API Management instance. If you fill this, a private endpoint will be created. |
| privateEndpointSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the subnet to use for the private endpoint. |
| privateDnsZoneResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The name of the resource group containing the private DNS zone for the private endpoint. |
| customProperties | object | <input type="checkbox"> | None | <pre>{}</pre> | Custom properties of the API Management service for setting enhanced security settings.<br>See [docs](https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Ciphers/)<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br><pre><br>{<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'False'<br>&nbsp;&nbsp;&nbsp;'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'False'<br>}<br></pre><br></details> |
| natGatewayState | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Property that can be used to enable NAT Gateway for this API Management service. |
| hostnameConfigurations | array | <input type="checkbox"> | None | <pre>[]</pre> | The custom domains configuration for this APIM instance. An array per custom domain consisting of type, hostname, certificate store amongst others.<br>Default you will have the builtin Gateway endpoint with hostname <your apim instancename>.azure-api.net<br>See [docs](https://learn.microsoft.com/en-us/azure/api-management/configure-custom-domain?tabs=custom). |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| apiManagementServiceName | string | The name of the created API Management service instance. |
| apiManagementServiceId | string | The Resource Id of the created API Management service instance. |
| apiManagementPrincipalId | string | The id of the system assigned principal attached to the API Management service instance. |
## Links
- [Bicep Microsoft.ApiManagement service](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service?pivots=deployment-language-bicep)


