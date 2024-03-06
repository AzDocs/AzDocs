# origins

Target Scope: resourceGroup

## Synopsis
Creating a origin GroupName with an optional origin in an existing FrontDoor profile with an existing endpoint.

## Description
Creating a origin GroupName endpoint with an optional origin in an existing FrontDoor profile with an existing endpoint.<br>
<pre><br>
module origin 'br:contosoregistry.azurecr.io/cdn/profiles/origingroups/origins.bicep' = [for (origin, index) in originGroupOrigins:{<br>
  name: format('{0}-{1}', take('${deployment().name}', 57), origin.name)<br>
  params: {<br>
    originGroupName: origingroup.outputs.originGroupName<br>
    originName: origin.name<br>
    originHostNameFqdn: origin.hostname<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    //originHostHeader: contains(origin, 'originHostHeader') ? origin.originHostHeader : ''<br>
    originEnabledState: origin.enabledState<br>
  }<br>
}]<br>
</pre><br>
<p>Creates an origin in a existing origin GroupName called originGroupName in an existing Frontdoor Profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| originName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of at least one origin to create. |
| originHostNameFqdn | string | <input type="checkbox" checked> | None | <pre></pre> | The FQDN of at least one origin to create. Specifies the address of the origin. Domain names, IPv4 addresses, and IPv6 addresses are supported.<br>This should be unique across all origins in an endpoint. |
| originGroupName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing origin GroupName to create the origins in. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile to create. |
| originHostHeader | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the host header value sent to the origin with each request. If you leave this blank, the request hostname determines this value.<br>Azure Front Door origins, such as Web Apps, Blob Storage, and Cloud Services require this host header value to match the origin hostname by default.<br>This overrides the host header defined at Endpoint. |
| originEnabledState | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether to enable health probes to be made against backends defined under backendPools. Health probes can only be disabled if there is a single enabled backend in single enabled backend pool. |
| privateLinkName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the private link service to use. If empty, no private link will be used. |
| privateLinkResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The existing private link service to use. Expected if privateLinkName is not empty.<br>Origin support for direct private endpoint connectivity is currently limited to:<br>Storage (Azure Blobs)<br>App Services<br>Internal load balancers (VMs can be behind these). |
| groupId | string | <input type="checkbox"> | None | <pre>''</pre> | The group id from the provider of resource the shared private link resource is for.<br>Example:<br>'blob' |
| privateLinkLocation | string | <input type="checkbox"> | None | <pre>''</pre> | The location of the shared private link resource |
| httpPort | int | <input type="checkbox"> | None | <pre>80</pre> | Specifies the value of the HTTP port. Must be between 1 and 65535. |
| httpsPort | int | <input type="checkbox"> | None | <pre>443</pre> | Specifies the value of the HTTPS port. Must be between 1 and 65535. |
| priority | int | <input type="checkbox"> | Value between 1-5 | <pre>1</pre> | Specifies the priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy.Must be between 1 and 5. |
| weight | int | <input type="checkbox"> | Value between 1-1000 | <pre>1000</pre> | Specifies the weight of the origin in a given origin group for load balancing. Must be between 1 and 1000. |
| enforceCertificateNameCheck | bool | <input type="checkbox"> | None | <pre>true</pre> | Whether to enable certificate name check at origin level.<br>If enabled, this will validate the certificate name at origin against the request hostname.<br>If disabled, this will not validate the certificate name at origin against the request hostname.<br>If not specified, this will default to true. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| originHostNameFqdn | string | The fqdn of the origin name created. |
| originName | string | The name of the origin created. |
| originNameId | string | The id of the origin created. |

## Links
- [Bicep Microsoft.Cdn profiles endpoint groupname origin](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/origingroups/origins?pivots=deployment-language-bicep)
