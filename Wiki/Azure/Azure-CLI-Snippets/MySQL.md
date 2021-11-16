[[_TOC_]]

# MySQL

When creating a MySQL database, you first need a [MySQL Server](/Azure/Azure-CLI-Snippets/MySQL/Create-MySQL-Server). There are some options to choose from:

## Networking

When creating a MySQL Server, we have enabled the ability to configure different ways of setting up the network for your MySQL Server.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-MySQL](/Azure/Azure-CLI-Snippets/MySQL/Add-Network-Whitelist-to-MySQL) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure MySQL Server.

## Create MySQL database

When creating the database, you can use the script [Create-MySQL-Database](/Azure/Azure-CLI-Snippets/MySQL/Create-MySQL-Database). Just provide your MySQL Server name and your database name.

## Tier

You have the following tiers to choose from: 'Basic', 'General Purpose' and 'Memory Optimized'. For more information on which to pick, go to: [MySQL Server sku's](https://docs.microsoft.com/en-us/azure/mysql/concepts-pricing-tiers)

## Logging

You have the ability to disable the diagnostic settings for your MySQL Server. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
