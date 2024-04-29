# privateDnsZones

Target Scope: resourceGroup

## Synopsis
Creating a private DNS zone

## Description
Creating a private DNS zone.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| privateDnsZoneName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the private DNS zone in which the private endpoint can be looked up.<br>Example<br>'privatelink.blob.&#36;{environment().suffixes.storage}' |
| registrationEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Auto register your eligible private endpoints within this DNS zone. Note: This should be default false unless you have a good reason to make this true. |
| virtualNetworkResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | The id of the virtual network you want to create the private endpoint in. Should be pre-existing.<br>Example:<br>'&#36;{subscription().id}/resourceGroups/&#36;{resourceGroup().name}/providers/Microsoft.Network/virtualNetworks/&#36;{virtualNetworkName}' |
| privateDnsLinkName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The name of the virtual network link in the DNS Zone.<br>After you create a private DNS zone in Azure, you will need to link a virtual network to it.<br>A virtual network can be linked to private DNS zone as a registration (autoregistration true) or as a resolution virtual network (autoregistration false). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| privateDnsZoneResourceId | string | The Resource ID of the upserted Private DNS Zone. |

## Examples
<pre>
module dnszone  'br:contosoregistry.azurecr.io/network/privatednszones:latest' ={
  name: '${deployment().name}-dnszone'
  params: {
    privateDnsLinkName: 'kvprivdnslinkname'
    privateDnsZoneName: 'privatelink${environment().suffixes.keyvaultDns}'
    virtualNetworkResourceId: '${subscription().id}/resourceGroups/${platformResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${virtualNetworkName}'
  }
}
TODO
}
</pre>
<p>Creates a private DNS zone with the name private DNS zone name.</p>

## Links
- [BICEP Private DNS zone](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones?pivots=deployment-language-bicep)
