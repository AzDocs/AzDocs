[[_TOC_]]

# Function Apps

When creating [Function Apps](/Azure/AzDocs-v1/Scripts/Functions/Create-Function-App), you have a lot of options to choose from. To make life as easy as possible, we've created some different scenario's that you are able to configure for your Function App:

## Deployment slots

While creating an Function App, you have the possibility to enable the use of deployment slots (which we wholeheartedly recommend).

Deployment slots are live apps with their own host name. These can then be used to validate your application and perhaps, most important of all, give you the ability to deploy without any downtime AND gives you a possibility to revert your changes immediately if something went wrong with your latest deployment.

When using this possiblity, we have made sure that the deployment slot gets configured correctly (including assignment of identities, networking, etc.).

Just enable the switch `EnableFunctionAppDeploymentSlot` and you're done. By default, the deployment slot name will be named `staging`, but you have the possibility to override this by providing a value for the parameter `FunctionAppDeploymentSlotName`.

## Networking

When creating an Function App, we have enabled the ability to configure different ways of setting up the network for your Function App.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail. Whenever you plan on using Private Endpoints or/and VNet whitelisting for resources this Function App should be able to reach, make sure to enable your VNet integration on your Function App to be able to reach those resources in a secure & compliant way. You can use [Add-VNET-integration-to-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Add-VNet-integration-to-Function-App) to enable VNet integration on your Function App. For more information about networking and how it works, please refer to [Networking](/Azure/General-Documentation/Networking)

You can use the [Add-Network-Whitelist-to-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Add-Network-Whitelist-to-Function-App) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Function App.

## Managed Identity

We automatically create a system-assigned identity for your Function App (and deployment slots). Nothing for you to do, just works!

## App Settings / Connection strings

App Settings and/or connection strings can be set by using the [Set-AppSettings-For-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Set-AppSettings-For-Function-App) and [Set-ConnectionStrings-For-Function-App](/Azure/AzDocs-v1/Scripts/Functions/Set-ConnectionStrings-For-Function-App). You can choose to deploy these settings to:

- Just your Function App
- Your Function App and ALL deployment slots (Set `ApplyToAllSlots` to `true`)
- A specific deployment slot

## Logging

You have the ability to disable the diagnostic settings for your Function App (and your deployment slots). When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.

## CORS

When creating a function application, the default [CORS](https://docs.microsoft.com/en-us/azure/azure-functions/security-concepts#restrict-cors-access) settings adds a couple of default urls that are needed if you want to test your functions from the Azure Portal. If you use the portal you also need to be able to call the function itself, so if you use a private-endpoint your browser needs to be able to call that private-endpoint.

If you want to be able to call the functionapp functions from a website (client site javascript) you need to add the url to `CORSUrls` parameter. If you don't want the default urls for the CORS urls, exclude them with the `DisableCORSPortalTestUrls` switch.
