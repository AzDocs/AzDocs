/*
.SYNOPSIS
Creating a Front Door Cdn Web Application Firewall Policy. This creates an Azure FrontDoor WAF policy.
.DESCRIPTION
This creates an Azure FrontDoor WAF policy.
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Cdn profiles](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('Specifies the name of the Azure Front Door WAF policy.')
@maxLength(128)
@minLength(1)
param wafPolicyName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Premium_AzureFrontDoor'

@description('Specifies if the WAF policy is in detection mode or prevention mode.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('Specifies if the policy is in enabled or disabled state. Defaults to Enabled if not specified.')
@allowed([
  'Enabled'
  'Disabled'
])
param wafPolicyEnabledState string = 'Enabled'

@description('''
Specifies the list of managed rule sets to configure on the WAF.
Example:
<details>
  <summary>Click to show example</summary>
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
''')
param wafManagedRuleSets array = []

@description('''
Specifies the list of custom rules to configure on the WAF.
Example:
<details>
  <summary>Click to show example</summary>
wafCustomRules: [
  {
    name: 'mygrubbe'
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
</details>
''')
param wafCustomRules array = []

@description('Specifies if the WAF policy managed rules will inspect the request body content.')
@allowed([
  'Enabled'
  'Disabled'
])
param wafPolicyRequestBodyCheck string = 'Enabled'

@description('Specifies the custom response body to return when a request is blocked by the WAF policy. The body must be specified in base64 encoding.')
param wafPolicyCustomBlockResponseBody string = ''

@description('Specifies the custom response status code to return when a request is blocked by the WAF policy.')
param wafPolicyCustomBlockResponseStatusCode int = 403

@description('Specifies the URL to redirect the request to when a request is blocked by the WAF policy.')
param wafPolicyRedirectUrl string = ''

// ===================================== Resources =====================================
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: wafPolicyName
  location: 'Global'
  tags: tags
  sku: {
    name: frontDoorSkuName
  }
  properties: {
    policySettings: {
      enabledState: wafPolicyEnabledState
      mode: wafPolicyMode
      requestBodyCheck: wafPolicyRequestBodyCheck

      customBlockResponseBody: wafPolicyCustomBlockResponseBody
      customBlockResponseStatusCode: wafPolicyCustomBlockResponseStatusCode
      redirectUrl: !empty(wafPolicyRedirectUrl) ? wafPolicyRedirectUrl : null
    }
    managedRules: {
      managedRuleSets: wafManagedRuleSets
    }
    customRules: {
      rules: wafCustomRules
    }
  }
}

@description('The resource id of the Front Door WAF policy.')
output wafPolicyId string = wafPolicy.id
@description('The name of the Front Door WAF policy.')
output wafPolicyName string = wafPolicy.name
