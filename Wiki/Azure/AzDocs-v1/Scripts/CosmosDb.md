[[_TOC_]]

# CosmosDB

When creating a [CosmosDb Account](/Azure/AzDocs-v1/Scripts/CosmosDb/Create-CosmosDbAccount). There are some options to choose from:

## Networking

When creating a CosmosDb account, we have enabled the ability to configure different ways of setting up the network for your CosmosDb account.

The following options are available:

- Public
- Private endpoints
- VNET whitelisting
- A combination of private endpoints and vnet whitelisting

**To be clear, we strongly advise against using public resources for obvious security implications.** Please refer to [Networking - When to use what?](/Azure/General-Documentation/Networking#when-to-use-what?) to find out what networking type suits you best. If you however do need to create a public resource, make sure to add the switch `-ForcePublic` to your task, if not, your task will fail.

You can use the [Add-Network-Whitelist-to-CosmosDb-Acount](/Azure/AzDocs-v1/Scripts/CosmosDb/Add-Network-Whitelist-to-CosmosDb-Account) script to whitelist IP's or subnets (VNet Whitelisting) on your Azure CosmosDb account.

## Throughput

To be able to use CosmosDb correctly, you will have to provision throughput for your container. This means that you have to specify in RU's (Request units) how many you need per second. This can be done on several levels inside your container, depending on which API you're using (e.g. Cassandra API or SQL API).

Calculating the amount of RU's that you need, can be done by using the [Capacity Calculator](https://cosmos.azure.com/capacitycalculator/).

### Provisioned throughput or Serverless

You have the ability to pick the 'Provisioned throughput' or the 'Serverless' option. The same operations can be performed in both modes, but the way you are billed is differently.

When choosing 'Provisioned throughput', you provision an amount of RU's in advance. This is useful when you have a sustainable amount of traffic on your CosmosDb account and you want predictable performance.

When choosing the 'Serverless' option, you only pay for the consumed RU's. This is useful when you have unpredictable traffic.

For both options there are advantages and disadvantages, for more information, see [Provisioned Throughput vs Serverless](https://docs.microsoft.com/en-us/azure/cosmos-db/throughput-serverless).

## API's

There are several API's available to be used with CosmosDb, e.g. SQL API, Cassandra API, Gremlin API, MongoDb etc.

At this moment, we only have scripts available to be able to create keyspaces and tables for the Cassandra API. In the future this will be expanded.

### Cassandra API

When you are using the Cassandra API in combination with your CosmosDb account, we have created scripts to do this (including the ability to set and update throughput), although we recommend to do this in your code.

Find more information here:

- [Keyspace/table creation](https://docs.microsoft.com/en-us/azure/cosmos-db/cassandra/manage-data-dotnet-core)

If you do want to create these by using the scripts, we have the following available:

- [Create-CosmosDbCassandraKeyspace](/Azure/AzDocs-v1/Scripts/CosmosDb/Create-CosmosDbCassandraKeyspace)
- [Create-CosmosDbCassandraTable](/Azure/AzDocs-v1/Scripts/CosmosDb/Create-CosmosDbCassandraTable)

## Logging

You have the ability to disable the diagnostic settings for your CosmosDb account. When you want to do this, add the switch `DiagnosticSettingsDisabled`. Next to that, you have the ability to specify which set of diagnostic logs you would like to enable.

For the category `logs` the parameter `DiagnosticSettingsLogs` can be used and for the category `metrics` the parameter `DiagnosticSettingsMetrics`. If you do not specify these settings, the default set (everything) will be enabled for your resource.

These logs get written to the Log Analytics Workspace that you specified.
