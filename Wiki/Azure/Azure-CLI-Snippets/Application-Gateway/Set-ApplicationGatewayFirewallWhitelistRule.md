[[_TOC_]]

# Description

This code will create or update a custom firewall rule for a Domain Name with a certain priority in the Application Gateway WAF policy for whitelisting one or more Ip addresses. All other Ip adresses will receive an 403 HTTP error for that Domain Name. In a Release Pipeline in AzureDevOps you should run this code in a Azure Powershell task (it requires a module not available in az cli).

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                           | Example Value                                  | Description                                                                                                                                                                                                               |
| ----------------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ApplicationGatewayResourceGroupName | `sharedservices-rg`                            | The name of the Resource Group where the application gateway lives.                                                                                                                                                       |
| ApplicationGatewayName              | `my-gateway-$(Release.EnvironmentName)`        | The name of the Application Gateway the WAF rule is created for.                                                                                                                                                          |
| ApplicationGatewayWafName           | `my-waf-$(Release.EnvironmentName)`            | DNS name for your site you want to configure the WAF custom rule for in the Application Gateway                                                                                                                           |
| IngressDomainName                   | `my.domain.com`                                | DNS name for your site you want to configure the WAF custom rule for in the Application Gateway                                                                                                                           |
| CIDRToWhitelist                     | `'10.0.0.0/8', '77.164.215.54', '192.169.8.9'` | IP ranges in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you use the script in a release task, remember not to enclose the variable name with quotes (") |
| Priority                            | `60`                                           | the Priority, other than the default calculated, you specifically want to use                                                                                                                                             |
| HighPriority                        |                                                | if added, the rule will receive a higher priority then the existing                                                                                                                                                       |

# Examples

Some examples how you can run the script locally

| Example |
| ------- |

| Set-ApplicationGatewayFirewallWhitelistRule -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'
Add an rule for www.google.nl for a local ip range (sidr notation). If this is the first rule, than the priority would be 50, or else the next available number upwards (next would be 51) |

Set-ApplicationGatewayFirewallWhitelistRule -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

Set-ApplicationGatewayFirewallWhitelistRule -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/16' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

    Add an rule for www.google.nl for a local ip range (sidr notation). If this is the first rule, than the priority would be 50, or else the next available number upwards (next would be 51).
    The second call would update the current rule with the new ip ranges and the same priority. It is overwritten because it is about the same domain.

Set-ApplicationGatewayFirewallWhitelistRule -HighPriority -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

    Add an rule for www.google.nl for a local ip range (sidr notation). If this is the first rule, than the priority would be 50, or else the next available number downwards (next would be 49)

Set-ApplicationGatewayFirewallWhitelistRule -HighPriority -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

Set-ApplicationGatewayFirewallWhitelistRule -HighPriority -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

    Add an rule for www.google.nl for a local ip range (sidr notation). If this is the first rule, than the priority would be 50, or else the next available number downwards (next would be 49)
    The second call would update the current rule with the new ip ranges and the same priority. It is overwritten because it is about the same domain.

Set-ApplicationGatewayFirewallWhitelistRule -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

Set-ApplicationGatewayFirewallWhitelistRule -HighPriority -IngressDomainName 'www.google.nl' -CIDRToWhitelist '10.0.0.0/8' -ApplicationGatewayResourceGroupName 'wafRG' -ApplicationGatewayWafName 'Waf'

    Add an rule for www.google.nl for a local ip range (sidr notation). If this is the first rule, than the priority would be 50, or else the next available number upwards (next would be 51)
    The second call would update the current rule with the new ip ranges and changes the priority. It is overwritten because it is about the same domain.

az network application-gateway waf-policy custom-rule list --policy-name 'ApplicationGatewayWafName' --resource-group 'ApplicationGatewayResourceGroupName' --subscription 'SubscriptionName'

    Lists all the customs rules set in the WAF.

az network application-gateway waf-policy custom-rule delete --name 'WAFRuleName' --policy-name 'ApplicationGatewayWafName' --resource-group 'ApplicationGatewayResourceGroupName' --subscription 'SubscriptionName'

    Delete a rule with the name 'WAFRuleName' from the WAF called 'ApplicationGatewayWafName'

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Set ApplicationGatewayFirewallWhitelistRule'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Application-Gateway/Set-ApplicationGatewayFirewallWhitelistRule.ps1'
               arguments: "-IngressDomainName '$(IngressDomainName)' -CIDRToWhitelist '$(CIDRToWhitelist)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayWafName '$(ApplicationGatewayWafName)' -HighPriority '$(HighPriority)' -Priority '$(Priority)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Set-ApplicationGatewayFirewallWhitelistRule.ps1)

# Links

- [Azure Powershell - Configure Application Gateway](https://docs.microsoft.com/en-us/powershell/module/az.network/?view=azps-5.4.0#application-gateway)
- [Azure Powershell - Create and manage Application Firewall Custom rule](https://docs.microsoft.com/en-us/powershell/module/az.network/new-azapplicationgatewayfirewallcustomrule)
- [Custom rules for Web Application Firewall v2 on Azure Application Gateway](https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview)
