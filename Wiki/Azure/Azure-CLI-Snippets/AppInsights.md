[[_TOC_]]

# AppInsights

When creating [Application Insights](/Azure/Azure-CLI-Snippets/AppInsights/Create-AppInsights-Resource), you have several options available to you:

## Workspace-based Application Insights

You have the possibility to create a workspace-based Application Insights, which basically means that your App Insights logs are being replicated to a Log Analytic Workspace. Just add the Log Analytics Workspace ResourceId of your choosing and you're good to go!

## Codeless

You have the possiblity to setup your Application Insights for your App Service or Function App in a codeless way. This means that when using the script [Create-Application-Insights-Extension-for-WebApps-codeless](</Azure/Azure-CLI-Snippets/AppInsights/Create-Application-Insights-Extension-for-WebApps-(codeless)>) or [Create-Application-Insights-Extension-for-FunctionApps-codeless](</Azure/Azure-CLI-Snippets/AppInsights/Create-Application-Insights-Extension-for-FunctionApps-(codeless)>) you can enable Application Insights for your application without having to change anything in your code (hence the codeless).

You can set this up for:

- Only your App Service / Function App
- You App Service / Function App and ALL deployment slots
- Only a specific deployment slot

## Logging

Diagnostic settings are enabled for your Application Insights resource. These logs get written to the Log Analytics Workspace that you specified. Easy as that!
