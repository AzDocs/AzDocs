[[_TOC_]]

# Container Registry

When [creating a Container Registry](/Azure/Azure-CLI-Snippets/Container-Registry/Create-Container-Registry), you have some options to choose from:

## Networking

When [creating a Container Registry](/Azure/Azure-CLI-Snippets/Container-Registry/Create-Container-Registry), we have enabled the ability to configure different ways of setting up the network for your Container Registry.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-Container-Registry](/Azure/Azure-CLI-Snippets/Container-Registry/Add-Network-Whitelist-to-Container-Registry) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Container Registry.

## Tier

You have the following tiers to choose from: 'Basic', 'Standard' and 'Premium'. For more information on which to pick, go to: [Container Registry Skus](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus)

## Logging

Diagnostic settings are enabled for your Container Registry. These logs get written to the Log Analytics Workspace that you specified. Easy as that!
