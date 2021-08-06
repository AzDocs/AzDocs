[[_TOC_]]

# PostgreSQL

When creating a PostgreSQL database, you first need a [PostgreSQL Server](/Azure/Azure-CLI-Snippets/PostgreSQL/Create-PostgreSQL-Server). There are some options to choose from:

## Networking

When creating a PostgreSQL Server, we have enabled the ability to configure different ways of setting up the network for your PostgreSQL Server.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-PostgreSQL](/Azure/Azure-CLI-Snippets/PostgreSQL/Add-Network-Whitelist-to-PostgreSQL) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure PostgreSQL Server.

## Create PostgreSQL database

When creating the database, you can use the script [Create-PostgreSQL-Database](/Azure/Azure-CLI-Snippets/PostgreSQL/Create-PostgreSQL-Database). Just provide your PostgreSQL Server name and your database name.

## Tier

You have the following tiers to choose from: 'Basic', 'General Purpose' and 'Memory Optimized'. For more information on which to pick, go to: [PostgreSQL Server sku's](https://docs.microsoft.com/en-us/azure/postgresql/concepts-pricing-tiers)

## Logging

Diagnostic settings are enabled for your PostgreSQL Server. These logs get written to the Log Analytics Workspace that you specified. Easy as that!