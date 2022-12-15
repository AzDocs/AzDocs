[[_TOC_]]

# Description

This snippet will enable the following:

- Enable AD authentication on your App Service in Advanced Mode
- Add an redirect uri to a specific app registration
- Adds a rewrite rule set if it does not exist to the Application Gateway, adds specific rewrite rules and conditions and assigns this to a specific Application Gateway rule.
- Update the healthprobe to accept http status code 401

In short, this is about what happens:
::: mermaid
sequenceDiagram
participant Client
participant AppGateway
participant AppService
participant AAD
Client->>AppGateway: Hey give me this page
AppGateway->>AppService: Hey give me this page
AppService-->>AppGateway: Please authenticate first!
AppGateway->>Client: Please authenticate first!
Client->>AAD: Hey i'd like to authenticate. I'm Rob!
AAD-->>Client: Ok. Here's your token!
Client->>AppGateway: Here's my token. Please give me the page.
AppGateway->>AppService: Here's the users token. Please give me the page.
AppService-->>AppGateway: Perfect! here's your page!
AppGateway-->>Client: Here's your page!
:::

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
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

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add AD Authentication for App Service"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/App-Services/Authentication/Add-AD-Authentication-for-App-Service.ps1"
    arguments: "-ServiceUserEmail '$(ServiceUserEmail)' -ServiceUserPassword '$(ServiceUserPassword)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceName '$(AppServiceName)' -AppRegistrationName '$(AppRegistrationName)' -AppRegistrationRedirectUri '$(AppRegistrationRedirectUri)' -ApplicationGatewayRewriteRuleSetName '$(ApplicationGatewayRewriteRuleSetName)' -ApplicationGatewayResourceGroupName '$(ApplicationGatewayResourceGroupName)' -ApplicationGatewayName '$(ApplicationGatewayName)' -ApplicationGatewayRequestRoutingRuleName '$(ApplicationGatewayRequestRoutingRuleName)' -ApplicationGatewayHealthProbeName '$(ApplicationGatewayHealthProbeName)'"
```

# Code

[Click here to download this script](../../../../../../src/App-Services/Authentication/Add-AD-Authentication-for-App-Service.ps1)

#Links

- [Azure webapp auth](https://docs.microsoft.com/en-us/cli/azure/webapp/auth?view=azure-cli-latest)
- [Azure app registration](https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_update)
- [Azure application gateway rewrite rules](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/rewrite-rule?view=azure-cli-latest)
- [Azure application gateway probes](https://docs.microsoft.com/en-us/cli/azure/network/application-gateway/probe?view=azure-cli-latest)
