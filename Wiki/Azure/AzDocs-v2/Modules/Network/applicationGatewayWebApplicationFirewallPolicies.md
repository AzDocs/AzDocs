# applicationGatewayWebApplicationFirewallPolicies

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| applicationGatewayWebApplicationFirewallPolicyName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resourcename of the Web Application Firewall policy name to be used. |
| customRules | array | <input type="checkbox"> | None | <pre>[]</pre> | The custom rules inside the policy. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#webapplicationfirewallcustomrule. |
| managedRuleSets | array | <input type="checkbox"> | None | <pre>[<br>  {<br>    ruleSetType: 'OWASP'<br>    ruleSetVersion: '3.1'<br>  }<br>]</pre> | The managed rule sets that are associated with the policy. This defaults to OWASP 3.1. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#managedruleset. |
| policySettings | object | <input type="checkbox"> | None | <pre>{<br>  requestBodyCheck: true<br>  maxRequestBodySizeInKb: 128<br>  fileUploadLimitInMb: 100<br>  state: 'Enabled'<br>  mode: 'Prevention'<br>}</pre> | The PolicySettings for policy. This defaults to an enabled policy in prevention mode. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#policysettings. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| applicationGatewayWebApplicationFirewallPolicyName | string | Ouputs the resource name of this application gateway waf policy. |

