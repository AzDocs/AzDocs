@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resourcename of the Web Application Firewall policy name to be used.')
@minLength(1)
@maxLength(80)
param applicationGatewayWebApplicationFirewallPolicyName string

@description('The custom rules inside the policy. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#webapplicationfirewallcustomrule.')
param customRules array = []

@description('The managed rule sets that are associated with the policy. This defaults to OWASP 3.1. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#managedruleset.')
param managedRuleSets array = [
  {
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.1'
  }
]

@description('The maximum request body size in megabytes. The default is 100.')
param fileUploadLimitInMb int = 100

@description('''
Sometimes WAF might block a request that you want to allow for your application. WAF exclusion lists allow you to omit certain request attributes from a WAF evaluation. The rest of the request is evaluated as normal, please refer to [the docs](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-configuration?tabs=bicep).
<details>
  <summary>Click to show example</summary>
  exclusions: [
    {
      // Exclude all cookies 
      matchVariable: 'RequestCookieNames'
      selectorMatchOperator: 'EqualsAny'
      selector: '*'
    }
  ]
</details>
''')
param exclusions array = []

@description('The PolicySettings for policy. This defaults to an enabled policy in prevention mode. For array/object structure, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies?tabs=bicep#policysettings.')
param policySettings object = {
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: fileUploadLimitInMb
  state: 'Enabled'
  mode: 'Prevention'
}

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
<details>
  <summary>Click to show example</summary>
  tags: {
    FirstTag: myvalue
    SecondTag: another value
  }
</details>
''')
param tags object = {}

@description('Upsert the Web Application Firewall with the given parameters.')
#disable-next-line BCP081
resource applicationGatewayWebApplicationFirewallPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-04-01' = {
  name: applicationGatewayWebApplicationFirewallPolicyName
  tags: tags
  location: location
  properties: {
    customRules: customRules
    policySettings: policySettings
    managedRules: {
      managedRuleSets: managedRuleSets
      exclusions: exclusions
    }
  }
}

@description('Ouputs the resource name of this application gateway waf policy.')
output applicationGatewayWebApplicationFirewallPolicyName string = applicationGatewayWebApplicationFirewallPolicy.name
