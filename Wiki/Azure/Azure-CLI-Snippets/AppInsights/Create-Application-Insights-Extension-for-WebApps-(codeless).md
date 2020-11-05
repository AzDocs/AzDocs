[[_TOC_]]

# Description

There are two ways to enable application monitoring for Azure App Services hosted applications:

- Agent-based application monitoring (ApplicationInsightsAgent).

This method is the easiest to enable, and no advanced configuration is required. It is often referred to as "runtime" monitoring (codeless deployment).

- Manually instrumenting the application through code by installing the Application Insights SDK.

This approach is much more customizable, but it requires adding a dependency on the Application Insights SDK NuGet packages.


**This snippet will add Agent-based application monitoring (ApplicationInsightsAgent) on your WebApp. This is the codeless deployment.**




# Parameters
Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.
| Parameter | Example Value | Description |
|--|--|--|
| appInsightsName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)-AppInsights` | The name of the AppInsights resource to use. |
| appServiceName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the WebApp resource the AppInsights settings will be configured on. |
| appServiceResourceGroupName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group where the AppService resource resides. Typically this is the same ResourceGroup as the appInsightsResourceGroupName |
| appInsightsResourceGroupName | `MyTeam-AzureTestApi-$(Release.EnvironmentName)` | The name of the Resource Group where the AppInsights resource resides. Typically this is the same ResourceGroup as the appInsightsResourceGroupName |


# Code
[Click here to download this script](../../../../src/AppInsights/Create-Application-Insights-Extension-for-WebApps-codeless.ps1)

# Links

- [Monitor Azure App Service performance](https://docs.microsoft.com/en-us/azure/azure-monitor/app/azure-web-apps?tabs=net)

- [Azure CLI - Automating Application Insights extension](https://markheath.net/post/automate-app-insights-extension)


