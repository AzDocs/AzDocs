[[_TOC_]]

# Description

This snippet will create an app service plan if it does not exist. It also adds the mandatory tags to the resources.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| AppServicePlanName | `Shared-ASP-$(Release.EnvironmentName)-Win-1` | The AppService Plan name. Mandatory and and this may be an existing App service plan, Windows App services should use a different App Service Plan then Linux App services |
| AppServicePlanSkuName | `S1` | The pricing tier that is going to be used. A list can be found here: [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/) |
| AppServicePlanResourceGroupName | `Shared-ASP-$(Release.EnvironmentName)-Win` | The ResourceGroup name where the AppServicePlan resides in. |
| AppServicePlanNumberOfWorkerInstances | `3` | OPTIONAL: The amount of worker instances you want for this appservice plan. For high availability, choose 2 or more. The default value (if you don't pass any value) will be 3. |

# Code

The snippet to create a Windows App Service Plan. Note that there can be no Linux App Service Plans in the same resourcegroup.

[Click here to download this script](../../../../src/App-Services/Create-App-Service-Plan-Windows.ps1)

# Links

- [Azure CLI - az appservice plan create](https://docs.microsoft.com/en-us/cli/azure/appservice/plan?view=azure-cli-latest#az-appservice-plan-create)
- [App Service Pricing for SKU's](https://azure.microsoft.com/nl-nl/pricing/details/app-service/windows/)
