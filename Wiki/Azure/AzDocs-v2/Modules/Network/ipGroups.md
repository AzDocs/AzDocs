# ipGroups

Target Scope: resourceGroup

## Synopsis
Bicep module to deploy an IP Group.

## Description
Bicep module to deploy an IP Group.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| ipGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | Specifies the name of the IP group. |
| ipGroupIpAddresses | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the IP addresses to include in the IP group. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| ipGroupName | string | The name of the IP group. |
| ipGroupResourceId | string | The resource ID of the IP group. |
## Examples
<pre>
module ipGroupGripDev 'br:contosoregistry.azurecr.io/network/ipgroups:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'ipgroup')
  params: {
    location: location
    ipGroupName: 'dev-frontend-ip-group'
    ipGroupIpAddresses: [ '10.100.198.32/27' ]
  }
}
</pre>
<p>Creates an IpGroup with the name dev-frontend-ip-group.</p>

## Links
- [Bicep Microsoft.Network ipgroups](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/ipgroups?pivots=deployment-language-bicep)


