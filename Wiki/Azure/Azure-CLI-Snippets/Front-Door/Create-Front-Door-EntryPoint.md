[[_TOC_]]

# Description

Add an entrypoint to the Azure Front Door profile.

# Parameters

| Parameter                              | Required                        | Example Value                         | Description                                                                        |
| -------------------------------------- | ------------------------------- | ------------------------------------- | ---------------------------------------------------------------------------------- |
| FrontDoorProfileName                   | <input type="checkbox" checked> | `azurefrontdoorprofile`               | The name of the Front Door profile                                                 |
| FrontDoorResourceGroup                 | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`       | The name of the resourcegroup the Front Door Profile resides in.                   |
| EndpointName                           | <input type="checkbox" checked> | `myendpoint`                          | The endpoint name.                                                                 |
| EndpointIsEnabled                      | <input type="checkbox" checked> | `Enabled`/`Disabled`                  | Determines if the endpoint is enabled. Defaults to `Enabled`.                      |
| OriginGroupName                        | <input type="checkbox" checked> | `myorigingroup`                       | The origin group the endpoint has to be attached to.                               |
| RuleSetName                            | <input type="checkbox">         | `myruleset`                           | The rule set name the endpoint can be attached to.                                 |
| RouteName                              | <input type="checkbox" checked> | `myroute`                             | The name for the route that will be attached to the endpoint.                      |
| CustomDomainHostName                   | <input type="checkbox" checked> | `*.wildcard.nl`                       | The custom domain host name the endpoint has to be attached to.                    |
| RouteForwardingProtocol                | <input type="checkbox">         | `HttpOnly`/`HttpsOnly`/`MatchRequest` | The forwarding protocol of the route. Defaults to `HttpsOnly`.                     |
| RouteHttpsRedirect                     | <input type="checkbox">         | `Enabled` / `Disabled`                | If the route has to redirect to Https. Defaults to `Enabled`.                      |
| RouteSupportedProtocols                | <input type="checkbox">         | `Http`/ `Https`                       | The supported protocol the route will use. Defaults to `Https`.                    |
| LinkRouteToDefaultDomain               | <input type="checkbox">         | `Enabled`/`Disabled`                  | The ability to route to the default front door domain. Defaults to `Disabled`.     |
| SecurityPolicyName                     | <input type="checkbox">         | `mysecuritypolicy`                    | The security policy name you want to add to your endpoint.                         |
| WAFPolicyName                          | <input type="checkbox">         | `mywafpolicy`                         | The name of your Web Application Firewall policy you want to add to your endpoint. |
| WAFPolicyResourceGroup                 | <input type="checkbox">         | `rg-policy`                           | The resourcegroup the Web Application Firewall policy resides in.                  |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Front Door EntryPoint"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Create-Front-Door-EntryPoint.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -EndpointName '$(EndpointName)'
        -EndpointIsEnabled '$(EndpointIsEnabled)'
        -OriginGroupName '$(OriginGroupName)'
        -RuleSetName '$(RuleSetName)'
        -RouteName '$(RouteName)'
        -CustomDomainHostName '$(CustomDomainHostName)'
        -RouteForwardingProtocol '(RouteForwardingProtocol)'
        -RouteHttpsRedirect '$(RouteHttpsRedirect)'
        -RouteSupportedProtocols '$(RouteSupportedProtocols)'
        -LinkRouteToDefaultDomain '$(LinkRouteToDefaultDomain)'
        -SecurityPolicyName '$(SecurityPolicyName)'
        -WAFPolicyName '$(WAFPolicyName)'
        -WAFPolicyResourceGroup '$(WAFPolicyResourceGroup)'
```

# Code

[Click here to download this script](../../../../src/Front-Door/Create-Front-Door-EntryPoint.ps1)

# Links

[Azure CLI - az afd endpoint create](https://docs.microsoft.com/en-us/cli/azure/afd/endpoint?view=azure-cli-latest#az-afd-endpoint-create)

[Azure CLI - az afd route create](https://docs.microsoft.com/en-us/cli/azure/afd/route?view=azure-cli-latest#az-afd-route-create)

[Azure CLI - az afd security policy create](https://docs.microsoft.com/en-us/cli/azure/afd/security-policy?view=azure-cli-latest#az-afd-security-policy-create)