[[_TOC_]]

# Description

Create a WAF policy.

# Parameters

| Parameter              | Required                        | Example Value                                                                 | Description                                               |
| ---------------------- | ------------------------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------- |
| WafPolicyName          | <input type="checkbox" checked> | `mypolicy`                                                                    | The name of the policy.                                   |
| WafPolicyResourceGroupName | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`                                               | The name of the resourcegroup the policy will reside in.  |
| WafPolicySku           | <input type="checkbox" checked> | `Classic_AzureFrontDoor`/`Premium_AzureFrontDoor` / `Standard_AzureFrontDoor` | The front door sku.                                       |
| WafPolicyFirewallMode  | <input type="checkbox">         | `Detection`/ `Prevention`                                                     | The policy firewall mode to set. Defaults to `Detection`. |


# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create WAF policy"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Web-Application-Firewall-Policies/Create-WAF-Policy.ps1"
    arguments: >
        -WafPolicyName '$(WafPolicyName)'
        -WafPolicyResourceGroupName '$(WafPolicyResourceGroupName)'
        -WafPolicySku '$(WafPolicySku)'
        -WafPolicyFirewallMode '$(WafPolicyFirewallMode)'
        -ResourceTags '$(ResourceTags)'
```

# Code

[Click here to download this script](../../../../src/Web-Application-Firewall-Policies/Create-WAF-Policy.ps1)

# Links

[Azure CLI - az network front-door waf-policy create](https://docs.microsoft.com/en-us/cli/azure/network/front-door/waf-policy?view=azure-cli-latest#az-network-front-door-waf-policy-create)