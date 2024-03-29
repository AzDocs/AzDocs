[[_TOC_]]

# Keyvault

When creating a [Keyvault](/Azure/AzDocs-v1/Scripts/Keyvault/Create-Keyvault), you have some options to choose from:

## Networking

When creating a Keyvault, we have enabled the ability to configure different ways of setting up the network for your Keyvault.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-Keyvault](/Azure/AzDocs-v1/Scripts/Keyvault/Add-Network-Whitelist-to-Keyvault) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure Keyvault.

## Granting permissions for Managed Identities

At some point, you would like your managed identity (for example for your App Service identity) to have the correct permissions to interact with your keyvault. We got you covered!
Just use one of the following scripts:

- [Grant-Me-Permissions-On-Keyvault](/Azure/AzDocs-v1/Scripts/Keyvault/Grant-Me-Permissions-On-Keyvault)
- [Set-Keyvault-Permissions-for-AppConfig-Identity](/Azure/AzDocs-v1/Scripts/Keyvault/Set-Keyvault-Permissions-for-AppConfig-Identity)
- [Set-Keyvault-Permissions-for-AppService-Identity](/Azure/AzDocs-v1/Scripts/Keyvault/Set-Keyvault-Permissions-for-AppService-Identity)

## Creating keys/secrets

The following scripts can be used to add keys or secrets to your keyvault: [Create-Keyvault-key](/Azure/AzDocs-v1/Scripts/Keyvault/Create-Keyvault-key) and [Create-Keyvault-Secret](/Azure/AzDocs-v1/Scripts/Keyvault/Create-Keyvault-Secret). _Note: If you've removed a key or secret before with the same name, but did not purge the key/secret, this script will fail. Be sure to have purged your keys/secrets in this particular case._

## Deleting keys/secrets

Currently there are no scripts to delete keys or secrets. Please do this in the Azure Portal.

## Logging

You have the ability to disable the diagnostic settings for your Keyvault. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
