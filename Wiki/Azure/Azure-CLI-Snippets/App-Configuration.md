[[_TOC_]]

# App Configuration

When creating an [App Configuration](/Azure/Azure-CLI-Snippets/App-Configuration/Create-App-Configuration), several options are configured for you:

## Networking

When creating an App Configuration, we have enabled the ability to configure different ways of setting up the network.

The following options are available:

- Public
- Private endpoints

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

## Managed Identity

We automatically create a system-assigned identity for your App Configuration. Nothing for you to do, just works!

## Linking Keys

We've provided scripts to be able to link your App Configuration keys to your App Service and/or your Keyvault. Just use [Link-AppConfig-Key-To-Keyvault-Secret](/Azure/Azure-CLI-Snippets/App-Configuration/Link-AppConfig-Key-To-Keyvault-Secret) or [Set-App-Configuration-ConnectionString-For-AppService](/Azure/Azure-CLI-Snippets/App-Configuration/Set-App-Configuration-ConnectionString-For-AppService).

## Logging

You have the ability to disable the diagnostic settings for your App Configuration. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
