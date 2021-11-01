[[_TOC_]]

# Description

This code will create or update a custom firewall rule for a specific domain name with a certain priority in the Application Gateway WAF. With this script you have the possibility to whitelist one or more ip addresses or to check based on a specific value for a specific request header. By default, the domain name will be added as a value to match on. In your pipeline, you should run this task in an Azure Powershell task (it requires a module not available in az cli).

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                                         | Required                        | Example Value                                  | Description                                                                                                                                                                                                               |
| ------------------------------------------------- | ------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ApplicationGatewayResourceGroupName               | <input type="checkbox" checked> | `sharedservices-rg`                            | The name of the Resource Group where the application gateway lives.                                                                                                                                                       |
| ApplicationGatewayName                            | <input type="checkbox" checked> | `my-gateway-$(Release.EnvironmentName)`        | The name of the Application Gateway the WAF rule is created for.                                                                                                                                                          |
| ApplicationGatewayWafName                         | <input type="checkbox" checked> | `my-waf-$(Release.EnvironmentName)`            | DNS name for your site you want to configure the WAF custom rule for in the Application Gateway                                                                                                                           |
| IngressDomainName                                 | <input type="checkbox" checked> | `my.domain.com`                                | DNS name for your site you want to configure the WAF custom rule for in the Application Gateway                                                                                                                           |
| CIDRToWhitelist                                   | <input type="checkbox">         | `'10.0.0.0/8', '77.164.215.54', '192.169.8.9'` | IP ranges in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you use the script in a release task, remember not to enclose the variable name with quotes (") |
| Priority                                          | <input type="checkbox">         | `60`                                           | The priority, other than the default calculated, you specifically want to use                                                                                                                                             |
| HighPriority                                      | <input type="checkbox">         | `n.a.`                                         | If added, the rule will receive a higher priority than the existing rules                                                                                                                                                 |
| ApplicationGatewayWafCustomRuleAction             | <input type="checkbox">         | `Block`'                                       | Two options are available for the action, 'Block' or 'Allow'. Defaults to 'Block'.                                                                                                                                        |
| ApplicationGatewayWafCustomRuleRequestHeader      | <input type="checkbox">         | `host` or `user-agent`                         | A request header you can specify to check in the custom defined rule.                                                                                                                                                     |
| ApplicationGatewayWafCustomRuleRequestHeaderValue | <input type="checkbox">         | `anyvalue`                                     | Based on this value, you can check if the request header has this specific value in the custom defined rule.                                                                                                              |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzurePowerShell@5
  displayName: "Set ApplicationGateway Firewall Whitelist rule"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    ScriptType: "FilePath"
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Application-Gateway/Set-ApplicationGatewayFirewallWhitelistRule.ps1"
    azurePowerShellVersion: "LatestVersion"
    pwsh: true
    ScriptArguments: "-IngressDomainName '$(IngressDomainName)' -CIDRToWhitelist $(CIDRToWhitelist) -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayWafName '$(ApplicationGatewayWafName)' -HighPriority -Priority '$(Priority)' -ApplicationGatewayWafCustomRuleAction '$(ApplicationGatewayWafCustomRuleAction)' -ApplicationGatewayWafCustomRuleRequestHeader '$(ApplicationGatewayWafCustomRuleRequestHeader)' -ApplicationGatewayWafCustomRuleRequestHeaderValue '$(ApplicationGatewayWafCustomRuleRequestHeaderValue)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Set-ApplicationGatewayFirewallWhitelistRule.ps1)

# Links

- [Azure Powershell - Configure Application Gateway](https://docs.microsoft.com/en-us/powershell/module/az.network/?view=azps-5.4.0#application-gateway)
- [Azure Powershell - Create and manage Application Firewall Custom rule](https://docs.microsoft.com/en-us/powershell/module/az.network/new-azapplicationgatewayfirewallcustomrule)
- [Custom rules for Web Application Firewall v2 on Azure Application Gateway](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview)
