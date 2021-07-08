[[_TOC_]]

# Description

This script will add security headers to http/https responses for the given application gateway routing rule.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| ApplicationGatewayResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg` | The name of the Resource Group for the shared resources for the Application Gateway. |
| ApplicationGatewayName | <input type="checkbox" checked> | `customer-appgw-$(Release.EnvironmentName)` | The name of the Application Gateway |
| IngressDomainName| <input type="checkbox" checked> | `website-example.com` | Name of the domain to adjust the security headers. |
| ContentSecurityPolicyValue | <input type="checkbox"> | `default-src 'self'` | Define the value of the Content Security Policy to use in case there is no one defined in the return headers.

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Add Application Gateway Security Headers'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Application-Gateway/Add-Application-Gateway-Security-Headers.ps1'
               arguments: "-ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -IngressDomainName '$(IngressDomainName)' -ContentSecurityPolicyValue '$(ContentSecurityPolicyValue)'"
```

# Code

[Click here to download this script](../../../../src/Application-Gateway/Add-Application-Gateway-Security-Headers.ps1)

# Links

- [AZ CLI - Configure Application Gateway rewrite rules](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/rewrite-rule?view=azure-cli-latest)
- [AZ CLI - Create an application gateway and rewrite HTTP headers](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-http-header-rewrite-powershell)
