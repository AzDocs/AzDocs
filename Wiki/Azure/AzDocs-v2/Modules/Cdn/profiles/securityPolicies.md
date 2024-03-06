# securityPolicies

Target Scope: resourceGroup

## Synopsis
Creating a security policy in an existing FrontDoor Cdn profile.

## Description
Creating a security policy in an existing FrontDoor Cdn profile.<br>
<pre><br>
module secpolicy 'br:contosoregistry.azurecr.io/cdn/profiles/securitypolicies.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 54), 'secpolicy')<br>
  params: {<br>
    afdEndpointsName: afdendpointappgw.outputs.frontDoorEndpointName<br>
    frontDoorName: frontDoorProfile.outputs.frontDoorName<br>
    securityPolicyName: 'securitypolicypub-tst-site-com'<br>
    wafPolicyName: frontdoorwafmypubtstonsitecom.outputs.wafPolicyName<br>
  }<br>
}<br>
</pre><br>
<p>Creates a security policy in an existing Frontdoor Cdn Profile.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| securityPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | Specifies the name of the security policy. |
| frontDoorName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Front Door Cdn profile to create. |
| securityPolicyPatternsToMatch | array | <input type="checkbox"> | None | <pre>[ '/*' ]</pre> | Specifies the list of patterns to match by the security policy. |
| wafPolicyName | string | <input type="checkbox" checked> | None | <pre></pre> | Specifies the name of the existing Azure Front Door WAF policy. |
| afdEndpointsName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing AFD endpoint. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| securityPolicyName | string | The name of the security policy created. |
| securityPolicyId | string | The ID of the security policy created. |

## Links
- [Bicep Microsoft.Cdn profiles endpoint groupname](https://learn.microsoft.com/en-us/azure/templates/microsoft.cdn/profiles/securitypolicies?pivots=deployment-language-bicep)
