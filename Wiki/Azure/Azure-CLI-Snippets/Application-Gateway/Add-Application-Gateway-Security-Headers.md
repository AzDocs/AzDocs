[[_TOC_]]

# Description
This script will add security headers to http/https responses for the given application gateway routing rule.

# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Required | Example Value | Description |
|--|--|--|--|
| ApplicationGatewayResourceGroupName | -[x] | `sharedservices-rg` | The name of the Resource Group for the shared resources for the Application Gateway. |
| ApplicationGatewayName | -[x] | `customer-appgw-$(Release.EnvironmentName)` | The name of the Application Gateway |
| ApplicationGatewayRequestRoutingRuleName | -[x] | `website-example-com-httpsrule` | Name of the routing rule, on which the default security headers should be appended. |
| ContentSecurityPolicyValue | -[ ] | `default-src 'self'` | Define the value of the  Content Security Policy to use in case there is no one defined in the return headers.

# Code
[Click here to download this script](../../../../src/Application-Gateway/Add-Application-Gateway-Security-Headers.ps1)

# Links

- [AZ CLI - Configure Application Gateway rewrite rules](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/rewrite-rule?view=azure-cli-latest)
- [AZ CLI - Create an application gateway and rewrite HTTP headers](https://docs.microsoft.com/en-us/azure/application-gateway/tutorial-http-header-rewrite-powershell)