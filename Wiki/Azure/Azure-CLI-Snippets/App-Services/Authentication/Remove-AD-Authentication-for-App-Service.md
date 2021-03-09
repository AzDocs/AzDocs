[[_TOC_]]

# Description

This snippet will disable/remove the following:

- Disable AD authentication on your App Service in Advanced Mode
- Removes an redirect uri to a specific app registration
- Removes specific rewrite rules and conditions
- Update the healthprobe to accept the default status codes

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| ServiceUserEmail | `my_user@domain.com` | The emailaddress of the service account to use |
| ServiceUserPassword | `Th15iSMyP@ssW0rD123!` | The password for the service account |
| AppServiceResourceGroupName | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the AppService resides in. |
| AppServiceName | `App-Service-name` | Name of the app service to set the whitelist on. |
| AppRegistrationName | `App-Registration-Name` | Name of the app service registration to add the redirect urls to. |
| AppRegistrationRedirectUri | `https://<app-url>/.auth/login/aad/callback` | The redirect url to add to the App Registration. This must always end with '.auth/login/aad/callback'. |
| ApplicationGatewayRewriteRuleSetName | `Headers` | The name of the rewrite rule set to create or add the rewrite urls to. |
| ApplicationGatewayResourceGroupName | `sharedservices-rg` | The name of the Application Gateway resource group. |
| ApplicationGatewayName | `application-gateway-name` | The name of the Application Gateway |
| ApplicationGatewayRequestRoutingRuleName | `rule-information-httpsrule` | The name of the request routing rule in the Application Gateway |
| ApplicationGatewayHealthProbeName | `health-probe-name` | The name of the health probe to update the status codes to |

# Code

[Click here to download this script](../../../../src/App-Services/Authentication/Remove-AD-Authentication-for-App-Service.ps1)

#Links

- [Azure webapp auth](https://docs.microsoft.com/en-us/cli/azure/webapp/auth?view=azure-cli-latest)
- [Azure app registration](https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_update)
- [Azure application gateway rewrite rules](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/rewrite-rule?view=azure-cli-latest)
- [Azure application gateway probes](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest)
