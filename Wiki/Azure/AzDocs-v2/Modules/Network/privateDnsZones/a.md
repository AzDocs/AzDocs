# a

Target Scope: resourceGroup

## Synopsis
Creating an A record in a private Dns zone

## Description
Creating an A record in a private Dns zone with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| privateDnsZoneName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The name of the private DNS zone in which the private endpoint can be looked up.<br>Example<br>'privatelink.blob.&#36;{environment().suffixes.storage}' |
| aRecordName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the A record in the private DNS zone.<br>Example:<br>'blob',<br>'*' |
| aRecordTtl | int | <input type="checkbox"> | None | <pre>300</pre> | The TTL for the A record |
| aRecordIpv4Address | string | <input type="checkbox" checked> | None | <pre></pre> | The ipv4 address for the A record |

## Examples
<pre>
module aRecord 'br:contosoregistry.azurecr.io/network/privatednszones/a:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'arecord')
  params: {
    privateDnsZoneName: managedEnvironment.outputs.privateDnsZoneName
    aRecordName: '*'
    aRecordIpv4Address: managedEnvironment.outputs.managedEnvironmentStaticIp
  }
}
</pre>
<p>Creates an Arecord in the private Dns zone for a container app</p>

## Links
- [Bicep Microsoft.Network Private Dns zone A Record](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/privatednszones/a?pivots=deployment-language-bicep)
