[[_TOC_]]

# Description

Create a custom rule for the WAF policy.

# Parameters

| Parameter              | Required                        | Example Value                                                                 | Description                                               |
| ---------------------- | ------------------------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------- |
| WafPolicyName          | <input type="checkbox" checked> | `mypolicy`                                                                    | The name of the policy.                                   |
| WafPolicyResourceGroupName | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`                                               | The name of the resourcegroup the policy will reside in.  |
| WWafPolicyCustomRuleName | <input type="checkbox" checked> | `custom-rule-name` | The name of the custom rule. | 
| WafPolicyCustomRuleConditionMatchVariable | <input type="checkbox" checked> | `RemoteAddr` | The match type for the custom rule. The following are available: `RemoteAddr`, `RequestMethod`, `QueryString`, `PostArgs`, `RequestUri`, `RequestHeader`, `RequestBody`, `Cookies`, `SocketAddr`. |
| WafPolicyCustomRuleConditionOperator | <input type="checkbox" checked> | `BeginsWith` | The condition operator for the match condition. The following are available: `Any`, `IPMatch`, `GeoMatch`, `Equal`, `Contains`, `LessThan`, `GreaterThan`, `LessThanOrEqual`, `GreaterThanOrEqual`, `BeginsWith`, `EndsWith`, `RegEx`. |
| WafPolicyCustomRuleConditionValues | <input type="checkbox" checked> | `@('test';)` | The values that will be needed for the match operation. | 
| WafPolicyCustomRuleConditionTransforms | <input type="checkbox"> | `LowerCase` | Transformations that can be done on the condition values. The following are available: `LowerCase`, `RemoveNulls`, `Trim`, `UpperCase`, `UrlDecode`, `UrlEncode`. |
| WafPolicyCustomRuleConditionNegate | <input type="checkbox"> | `$false` | The negate of the rule. Defaults to `false`. |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add a custom condition to a WAF Policy custom rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Web-Application-Firewall-Policies/Create-WAF-Policy-Custom-Condition.ps1"
    arguments: >
        -WafPolicyName '$(WafPolicyName)'
        -WafPolicyResourceGroupName '$(WafPolicyResourceGroupName)'
        -WafPolicyCustomRuleName '$(WafPolicyCustomRuleName)'
        -WafPolicyCustomRuleConditionMatchVariable '$(WafPolicyCustomRuleConditionMatchVariable)'
        -WafPolicyCustomRuleConditionOperator '$(WafPolicyCustomRuleConditionOperator)'
        -WafPolicyCustomRuleConditionValues $(WafPolicyCustomRuleConditionValues)
        -WafPolicyCustomRuleConditionTransforms '$(WafPolicyCustomRuleConditionTransforms)'
        -WafPolicyCustomRuleConditionNegate $(WafPolicyCustomRuleConditionNegate)
```

# Code

[Click here to download this script](../../../../src/Web-Application-Firewall-Policies/Create-WAF-Policy-Custom-Condition.ps1)

# Links

[Azure CLI - az network front-door waf-policy rule](https://learn.microsoft.com/en-us/cli/azure/network/front-door/waf-policy/rule?view=azure-cli-latest)

[Azure CLI - az network front-door waf-policy rule match-condition](https://learn.microsoft.com/en-us/cli/azure/network/front-door/waf-policy/rule/match-condition?view=azure-cli-latest)