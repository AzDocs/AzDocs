[[_TOC_]]

# RedisCache

When creating a [RedisCache instance](/Azure/AzDocs-v1/Scripts/RedisCache/Create-RedisCache-Instance). There are some options to choose from:

## Networking

When creating a RedisCache instance, we have enabled the ability to configure different ways of setting up the network for your RedisCache instance.

The following options are available:

- Public
- Private endpoints

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-RedisCache](/Azure/AzDocs-v1/Scripts/RedisCache/Add-Network-Whitelist-to-RedisCache) script to whitelist IP's on your Azure RedisCache.

## Logging

You have the ability to disable the diagnostic settings for your RedisCache instance. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
