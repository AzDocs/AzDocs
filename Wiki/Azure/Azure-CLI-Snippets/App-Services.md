[[_TOC_]]

# App Services

When creating [App Services](/Azure/Azure-CLI-Snippets/App-Services/Create-Web-App), you have a lot of options to choose from. To make life as easy as possible, we've created some different scenario's that you are able to configure for your App Service:

## Deployment slots

While creating an App Service, you have the possibility to enable the use of deployment slots (which we wholeheartedly recommend).

Deployment slots are live apps with their own host name. These can then be used to validate your application and perhaps, most important of all, give you the ability to deploy without any downtime AND gives you a possibility to revert your changes immediately if something went wrong with your latest deployment.

When using this possiblity, we have made sure that the deployment slot gets configured correctly (including assignment of identities, networking, etc.).

Just enable the switch `EnableAppServiceDeploymentSlot` and you're done. By default, the deployment slot name will be named `staging`, but you have the possibility to override this by providing a value for the parameter `AppServiceDeploymentSlotName`.

## Networking

When creating an App Service, we have enabled the ability to configure different ways of setting up the network for your App Service.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail. Whenever you plan on using Private Endpoints or/and VNet whitelisting for resources this App Service should be able to reach, make sure to enable your VNet integration on your App Service to be able to reach those resources in a secure & compliant way. You can use [Add-VNET-integration-to-AppService](/Azure/Azure-CLI-Snippets/App-Services/Add-VNet-integration-to-AppService) to enable VNet integration on your App Service. For more information about networking and how it works, please refer to [Networking](/Azure/Documentation/Networking)

You can use the [Add-Network-Whitelist-to-App-Service](/Azure/Azure-CLI-Snippets/App-Services/Add-Network-Whitelist-to-App-Service) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure App Service.

## Managed Identity

We automatically create a system-assigned identity for your App Service (and deployment slots). Nothing for you to do, just works!

## Authentication

When you want to use AAD authentication right out of the box, because you're still in the process of setting things up but do want the added security, or if this is just enough for you, then we have the solution. The script [Add-AD-Authentication-for-App-Service](/Azure/Azure-CLI-Snippets/App-Services/Authentication/Add-AD-Authentication-for-App-Service) can be used to enable all the correct settings for this, which include redirect-uri's, rewrite rule sets etc.

## App Settings / Connection strings

App Settings and/or connection strings can be set by using the [Set-AppSettings-For-AppService](/Azure/Azure-CLI-Snippets/App-Services/Set-AppSettings-For-AppService) and [Set-ConnectionStrings-For-AppService](/Azure/Azure-CLI-Snippets/App-Services/Set-ConnectionStrings-For-AppService). You can choose to deploy these settings to:

- Just your App Service
- Your App Service and ALL deployment slots (Set `ApplyToAllSlots` to `true`)
- A specific deployment slot

## Logging

You have the ability to disable the diagnostic settings for your App Service (and your deployment slots). When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.

## Containers

It is possible to deploy a container inside an App Service. This can be done by specifying the container image name you would like to use when creating the App Service. _Note: This can only be used for App Services that are based on the Linux-system._
