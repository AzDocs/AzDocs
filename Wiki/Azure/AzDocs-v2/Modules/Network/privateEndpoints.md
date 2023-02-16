# privateEndpoints

Target Scope: resourceGroup

## Synopsis
Creating a private endpoint

## Description
Creating a private endpoint for a resource.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the private endpoint should be created. |
| targetResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The target resource id where this private endpoint is created for. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| privateEndpointName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name for the private endpoint resource to be upserted. |
| virtualNetworkName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the virtual network you want to create the private endpoint in. Should be pre-existing. |
| subnetName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the subnet in the virtual network you want to create the private endpoint in. Should be pre-existing. |
| virtualNetworkResourceId | string | <input type="checkbox"> | None | <pre>'&#36;{subscription().id}/resourceGroups/&#36;{resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/&#36;{virtualNetworkName}'</pre> | String containing the resource id of the virtual network you want to create the private endpoint in.<br>Example:<br>'&#36;{subscription().id}/resourceGroups/&#36;{resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/&#36;{virtualNetworkName}' |
| privateDnsZoneName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the private DNS zone in which the private endpoint can be looked up.<br>Example:<br>'privatelink.blob.&#36;{environment().suffixes.storage}' |
| privateDnsLinkName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the virtual network link in the DNS Zone.<br>After you create a private DNS zone in Azure, you will need to link a virtual network to it.<br>A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false). |
| privateDnsZoneResourceGroupName | string | <input type="checkbox"> | None | <pre>az.resourceGroup().name</pre> | The name of the resourcegroup where the private DNS zone for the private endpoint resides or will reside in. |
| privateEndpointGroupId | string | <input type="checkbox" checked> | None | <pre></pre> | The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to.<br>For example: blob, queue, table, file, registry, sites<br>Example<br>[<br>&nbsp;&nbsp;&nbsp;'sqlServer'<br>] |
| privateLinkServiceConnectionName | string | <input type="checkbox"> | None | <pre>'&#36;{privateEndpointName}-&#36;{privateEndpointGroupId}-&#36;{virtualNetworkName}-&#36;{subnetName}'</pre> | Optional parameter to change the default connection name. |
| registrationEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Auto register your eligible private endpoints within this DNS zone. Note: This should be default false unless you have a good reason to make this true |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
## Examples
<pre>
module privateendpoint 'br:acrazdocsprd.azurecr.io/network/privateendpoints:latest' = {
  name: '${deployment().name}-stgpetest'
  params: {
    privateDnsLinkName: 'stgprivdnslinkname'
    privateDnsZoneName: 'privatelink.blob.${environment().suffixes.storage}'
    privateEndpointGroupId: 'blob'
    subnetName: privateEndpointSubnetName
    targetResourceId: storageAccount.outputs.storageAccountResourceId
    privateEndpointName: 'myStgPrivateEndpoint'
    virtualNetworkName: virtualNetworkName
    virtualNetworkResourceId: virtualNetworkResourceId
    location: location
    privateDnsZoneResourceGroupName: privateDnsZoneResourceGroupName
  }
}
</pre>
<p>Creates a private endpoint with the name privateEndpointName. You can decide to host the DNS zones in a different resourcegroup than the VNET resourcegroup.</p>

## Links
- [BICEP Private Endpoint](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privateendpoints?pivots=deployment-language-bicep)


