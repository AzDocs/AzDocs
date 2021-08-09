[[_TOC_]]

# ServiceBus

When creating a [Servicebus Namespace](/Azure/Azure-CLI-Snippets/ServiceBus/Create-ServiceBus-Namespace), you have some options to choose from:

## Networking

When creating a Servicebus Namespace, we have enabled the ability to configure different ways of setting up the network for your Servicebus Namespace.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-ServiceBus-Namespace](/Azure/Azure-CLI-Snippets/ServiceBus/Add-Network-Whitelist-to-ServiceBus-Namespace) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Servicebus Namespace.

_Note: Private endpoints and VNET whitelisting can only be used for the tier Premium._

## Logging

Diagnostic settings are enabled for your Servicebus. These logs get written to the Log Analytics Workspace that you specified. Easy as that!
