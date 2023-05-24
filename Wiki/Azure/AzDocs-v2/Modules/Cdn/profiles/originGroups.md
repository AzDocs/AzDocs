# originGroups

Target Scope: resourceGroup

## Synopsis
Creating a origin GroupName with an optional origin in an existing FrontDoor profile with an existing endpoint.

## Description
Creating a origin GroupName endpoint with an optional origin in an existing FrontDoor profile with an existing endpoint.<br>
<pre><br>
module origingroup 'br:contosoregistry.azurecr.io/cdn/profiles/origingroups.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 52), 'origingroup')<br>
  params: {<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    originGroupName: originGroupName<br>
  }<br>
}<br>
</pre><br>
<p>Creates an origin GroupName called originGroupName in an existing Frontdoor Cdn Profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| originGroupName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the origin GroupName to create. This must be unique within the Front Door profile. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile. |
| sampleSize | int | <input type="checkbox"> | None | <pre>4</pre> | Specifies the number of samples to consider for load balancing decisions. |
| successfulSamplesRequired | int | <input type="checkbox"> | None | <pre>3</pre> | Specifies the number of samples within the sample period that must succeed. |
| additionalLatencyInMilliseconds | int | <input type="checkbox"> | None | <pre>50</pre> | Specifies the additional latency in milliseconds for probes to fall into the lowest latency bucket. |
| probePath | string | <input type="checkbox"> | None | <pre>'/'</pre> | Specifies path relative to the origin that is used to determine the health of the origin. |
| probeRequestType | string | <input type="checkbox"> | `'GET'` or `'HEAD'` or `'NotSet'` | <pre>'HEAD'</pre> | Specifies the health probe request type. |
| probeProtocol | string | <input type="checkbox"> | `'Http'` or `'Https'` or `'NotSet'` | <pre>'Http'</pre> | Specifies the health probe protocol. |
| probeIntervalInSeconds | int | <input type="checkbox"> | None | <pre>60</pre> | Specifies the number of seconds between health probes.Default is 240 seconds. |
| sessionAffinityState | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Disabled'</pre> | Specifies whether to allow session affinity on this host. Valid options are Enabled or Disabled. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| originGroupName | string | The origin groupname created. |
| originGroupResourceId | string | The origin groupname resource id created. |
## Links
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/origingroups?pivots=deployment-language-bicep)


