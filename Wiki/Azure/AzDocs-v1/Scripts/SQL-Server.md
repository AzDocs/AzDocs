[[_TOC_]]

# SQL Server

When creating a SQL database, you first need a [SQL Server](/Azure/AzDocs-v1/Scripts/SQL-Server/Create-SQL-Server). There are some options to choose from:

## Networking

When creating a MySQL Server, we have enabled the ability to configure different ways of setting up the network for your MySQL Server.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-Sql-Server](/Azure/AzDocs-v1/Scripts/SQL-Server/Add-Network-Whitelist-to-Sql-Server) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure SQL Server.

## Elastic pools

After you've created your SQL Server, you can choose to create an elastic pool. This can help you by ensuring the databases get the performance resources they need when they need it and all of this within a predictable budget. You can setup elastic pools based upon several tiers.

### Elastic pool Tiers

When choosing a tier for an elastic pool, you can pick different options:

#### DTU

When using the DTU (Database Transaction Unit) model when creating an elastic pool, you pay one fixed price for your IO/Memory/Storage and backup retention. This option is simpler when you're setting up simple databases.

The editions you can pick from: 'Basic', 'Standard' and 'Premium'. To understand which options you have per edition, see: [Azure - DTU limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-dtu-elastic-pools)

#### VCore

When using the VCore (Virtual Core) model when creating an elastic pool, you pay separately for your compute and seperate for your storage. This option is useful when you want to have more insight and flexibility in managing costs.

The editions you can pick from: 'GeneralPurpose', 'BusinessCritical'. To understand which options you have per edition, see [Azure - VCore limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)

## Create SQL database

When creating the database, you can use the script [Create-SQL-Database](/Azure/AzDocs-v1/Scripts/SQL-Server/Create-SQL-Database).

### SQL database tier

When you don't add the SQL database to an elastic pool, you also have the possibility to set the database up based on different tiers:

- [Azure - DTU limits for single SQL database](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tiers-dtu#single-database-dtu-and-storage-limits)
- [Azure - VCore limits for single SQL database](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tiers-sql-database-vcore)

## Logging

You have the ability to disable the diagnostic settings for your SQL Server. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
