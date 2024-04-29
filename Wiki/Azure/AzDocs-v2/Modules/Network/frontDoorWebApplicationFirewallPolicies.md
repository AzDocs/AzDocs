# frontDoorWebApplicationFirewallPolicies

Target Scope: resourceGroup

## Synopsis
Creating a Front Door Cdn Web Application Firewall Policy. This creates an Azure FrontDoor WAF policy.

## Description
This creates an Azure FrontDoor WAF policy.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| wafPolicyName | string | <input type="checkbox" checked> | Length between 1-128 | <pre></pre> | Specifies the name of the Azure Front Door WAF policy. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| frontDoorSkuName | string | <input type="checkbox"> | `'Standard_AzureFrontDoor'` or `'Premium_AzureFrontDoor'` | <pre>'Premium_AzureFrontDoor'</pre> | The name of the SKU to use when creating the Front Door profile. |
| wafPolicyMode | string | <input type="checkbox"> | `'Detection'` or `'Prevention'` | <pre>'Prevention'</pre> | Specifies if the WAF policy is in detection mode or prevention mode. |
| wafPolicyEnabledState | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Specifies if the policy is in enabled or disabled state. Defaults to Enabled if not specified. |
| wafManagedRuleSets | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the list of managed rule sets to configure on the WAF.<br>Example:<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br>wafManagedRuleSets: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleSetType: 'Microsoft_DefaultRuleSet'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleSetVersion: '2.0'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleSetAction: 'Block'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleGroupOverrides: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;exclusions: []<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleSetType: 'Microsoft_BotManagerRuleSet'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleSetVersion: '1.0'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleGroupOverrides: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;exclusions: []<br>&nbsp;&nbsp;&nbsp;}<br>] |
| wafCustomRules | array | <input type="checkbox"> | None | <pre>[]</pre> | Specifies the list of custom rules to configure on the WAF.<br>Example:<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br>wafCustomRules: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'mygrubbe'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;enabledState: 'Enabled'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;priority: 100<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ruleType: 'RateLimitRule'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rateLimitDurationInMinutes: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;rateLimitThreshold: 25<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;matchConditions: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;matchVariable: 'RequestUri'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'Contains'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;negateCondition: false<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;matchValue: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/api/'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;transforms: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;action: 'Block'<br>&nbsp;&nbsp;&nbsp;}<br>]<br></details> |
| wafPolicyRequestBodyCheck | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Specifies if the WAF policy managed rules will inspect the request body content. |
| wafPolicyCustomBlockResponseBody | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the custom response body to return when a request is blocked by the WAF policy. The body must be specified in base64 encoding. |
| wafPolicyCustomBlockResponseStatusCode | int | <input type="checkbox"> | None | <pre>403</pre> | Specifies the custom response status code to return when a request is blocked by the WAF policy. |
| wafPolicyRedirectUrl | string | <input type="checkbox"> | None | <pre>''</pre> | Specifies the URL to redirect the request to when a request is blocked by the WAF policy. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| wafPolicyId | string | The resource id of the Front Door WAF policy. |
| wafPolicyName | string | The name of the Front Door WAF policy. |

## Examples
<pre>
module frontDoorWaf 'br:contosoregistry.azurecr.io/network/frontdoorwebapplicationfirewallpolicies:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'frontdoorwaf')
  params: {
    wafPolicyName: wafPolicyPubTstName
    wafPolicyCustomBlockResponseBody: 'QmxvY2tlZCBieSBXQUY=' // Blocked by WAF (base64 encoded)
    wafManagedRuleSets: [
      {
        ruleSetType: 'Microsoft_DefaultRuleSet'
        ruleSetVersion: '2.0'
        ruleSetAction: 'Block'
        ruleGroupOverrides: []
        exclusions: []
      }
      {
        ruleSetType: 'Microsoft_BotManagerRuleSet'
        ruleSetVersion: '1.0'
        ruleGroupOverrides: []
        exclusions: []
      }
    ]
    wafCustomRules: [
      {
        name: 'pubbe'
        enabledState: 'Enabled'
        priority: 100
        ruleType: 'RateLimitRule'
        rateLimitDurationInMinutes: 1
        rateLimitThreshold: 25
        matchConditions: [
          {
            matchVariable: 'RequestUri'
            operator: 'Contains'
            negateCondition: false
            matchValue: [
              '/api/'
            ]
            transforms: []
          }
        ]
        action: 'Block'
      }
    ]
  }
}
</pre>
<p>Creates a Front Door Cdn Web Application Firewall Policy with the name wafPolicyPubTstName.</p>

## Links
- [Bicep Microsoft.Cdn profiles](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies?pivots=deployment-language-bicep)
