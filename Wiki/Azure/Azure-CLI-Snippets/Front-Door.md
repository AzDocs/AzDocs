[[_TOC_]]

# Front Door

When creating the Azure Front Door, you have two options to choose from: 

- Premium_AzureFrontDoor
- Standard_AzureFrontDoor

## Standard

When creating the resource, you have the possiblity to create a Azure Front Door - Standard. 
This is the standard profile that has no option to make use of private endpoints. For more information on the differences between Premium and Standard, please see [Tier comparison](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison).

## Premium
When creating the resource, you have the possibility to create a Azure Front Door - Premium. With the premium tier you have the option to make use of private endpoints. For more information on the differences between Premium and Standard, please see [Tier comparison](https://docs.microsoft.com/en-us/azure/frontdoor/standard-premium/tier-comparison).

## Networking

For the Standard type, the following options are available:

- Public

For the Premium type, the following options are available: 
- Private Endpoints

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. 

### Service Tag

To be able to use the **Standard** Azure Front Door, it is possible to make use of network tagging. This means that when your resource, for example a function app, is inside a VNet, you will be able to allow the network with the specified tag to access the function app. The script `Add-Front-Door-ServiceTag-To-Resource.ps1` makes this possible. 

We do advise to also make use of the `ServiceTagHttpHeaders` parameter and make sure only your Front Door is able to access the function app, see [Lock Down Access - Azure Front Door](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-faq#how-do-i-lock-down-the-access-to-my-backend-to-only-azure-front-door-).

For the **Premium** Azure Front Door, you will make use of the private endpoint connection and no network tagging is required.

## Logging

You have the ability to disable the diagnostic settings for your Front Door. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.