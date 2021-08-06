[[_TOC_]]

# RedisCache

When creating a [RedisCache instance](/Azure/Azure-CLI-Snippets/RedisCache/Create-RedisCache-Instance). There are some options to choose from:

## Networking

When creating a RedisCache instance, we have enabled the ability to configure different ways of setting up the network for your RedisCache instance.

The following options are available:

- Public
- Private endpoints

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-RedisCache](/Azure/Azure-CLI-Snippets/RedisCache/Add-Network-Whitelist-to-RedisCache) script to whitelist IP's on your Azure RedisCache.

## Logging

Diagnostic settings are enabled for your RedisCache instance. These logs get written to the Log Analytics Workspace that you specified. Easy as that!
