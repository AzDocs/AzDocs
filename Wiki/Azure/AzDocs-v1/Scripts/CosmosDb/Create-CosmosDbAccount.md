[[_TOC_]]

# Description

This snippet will create a CosmosDB account if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                    | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                                                                                                    |
| -------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDbAccountName                          | <input type="checkbox" checked> | `somecosmosdb$(Release.EnvironmentName)`                                                                                                        | The name for the CosmosDB Account resource. It's recommended to use just alphanumerical characters and hyphens.                                                                                                                                                                                                |
| CosmosDbAccountResourceGroupName             | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)`                                                                                                     | The name of the resourcegroup you want your CosmosDB account to be created in                                                                                                                                                                                                                                  |
| CosmosDbKind                                 | <input type="checkbox" checked> | `Cassandra`                                                                                                                                     | The kind of database to use in this cosmos account. Current options are: `GlobalDocumentDB`, `MongoDB`, `Parse` and `Cassandra`.                                                                                                                                                                               |
| CosmosDbCapabilities                         | <input type="checkbox">         | `EnableTable`                                                                                                                                   | Set custom capabilities on the Cosmos DB database account. Find out more about capabilities in the officiel [MS docs](https://docs.microsoft.com/en-us/azure/cosmos-db/).                                                                                                                                      |
| CosmosDbBackupIntervalInMinutes              | <input type="checkbox">         | `10`                                                                                                                                            | The frequency(in minutes) with which backups are taken (only for accounts with periodic mode backups).                                                                                                                                                                                                         |
| CosmosDbBackupRetentionInHours               | <input type="checkbox">         | `24`                                                                                                                                            | The time(in hours) for which each backup is retained (only for accounts with periodic mode backups).                                                                                                                                                                                                           |
| CosmosDbDefaultConsistencyLevel              | <input type="checkbox">         | `Eventual`                                                                                                                                      | Default consistency level of the Cosmos DB database account. Options are: `BoundedStaleness`, `ConsistentPrefix`, `Eventual`, `Session`, `Strong`.                                                                                                                                                             |
| CosmosDbEnableAutomaticFailover              | <input type="checkbox">         | `true`/`false`                                                                                                                                  | Enables automatic failover of the write region in the rare event that the region is unavailable due to an outage. Automatic failover will result in a new write region for the account and is chosen based on the failover priorities configured for the account.                                              |
| CosmosDbEnableMultipleWriteCosmosDbLocations | <input type="checkbox">         | `true`/`false`                                                                                                                                  | Enable Multiple Write Locations.                                                                                                                                                                                                                                                                               |
| CosmosDbKeyvaultKeyUri                       | <input type="checkbox">         | `https://<my-vault>.vault.azure.net/keys/<my-key>`                                                                                              | Data stored in your Azure Cosmos account is automatically and seamlessly encrypted with keys managed by Microsoft (service-managed keys). Optionally, you can choose to add a second layer of encryption with keys you manage (customer-managed keys). This parameter should be the URL to the encryption key. |
| CosmosDbLocations                            | <input type="checkbox">         | `@(@{regionName="westeurope"; failoverPriority=0; isZoneRedundant=$False}, @{regionName="uksouth";failoverPriority=1;isZoneRedundant=$True})`   | If you enable `CosmosDbEnableMultipleWriteCosmosDbLocations`, this parameter will specify information about the locations you want to use. make sure to pass an array of objects with the following parameters: `regionName`, `failoverPriority` & `isZoneRedundant` (see example).                            |
| CosmosDbMaxStalenessInterval                 | <input type="checkbox">         | `5`                                                                                                                                             | When used with Bounded Staleness consistency, this value represents the time amount of staleness (in seconds) tolerated. Accepted range for this value is 1 - 100.                                                                                                                                             |
| CosmosDbMaxStalenessPrefix                   | <input type="checkbox">         | `500`                                                                                                                                           | When used with Bounded Staleness consistency, this value represents the number of stale requests tolerated. Accepted range for this value is 1 - 2,147,483,647.                                                                                                                                                |
| CosmosMongoDbServerVersion                   | <input type="checkbox">         | `4.2`                                                                                                                                           | Valid only for MongoDB accounts. Accepted values: 3.2, 3.6, 4.0 and 4.2.                                                                                                                                                                                                                                                |
| ForcePublic                                  | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`).                                                                      |
| LogAnalyticsWorkspaceResourceId              | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                                                                                                                                                          |
| EnableLogDiagnosticSettings                  | <input type="checkbox" >        | `$true`                                                                                                                                         | The ability to enable standard Diagnostic settings in the category log. See Diagnostic Settings - Logs for which categories get enabled. Default value is `$true`.                                                                                                                                             |
| EnableMetricDiagnosticSettings               | <input type="checkbox">         | `$true`                                                                                                                                         | The ability to enable standard Diagnostic settings in the category metrics. See Diagnostic Settings - Metrics for which categories get enabled. Default value is `$true`.                                                                                                                                      |
| DiagnosticSettingsLogs                       | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                                                                                                                    |
| DiagnosticSettingsMetrics                    | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                                                                                                                              |
| DiagnosticSettingsDisabled                   | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                                                                                                                              |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                        | Description                                                       |
| -------------------------------- | ------------------------------- | ------------------------------------ | ----------------------------------------------------------------- |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your resource, resides in. |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the resource is in                           |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The name of the subnet the resource is in                         |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                    | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                                                                   |
| -------------------------------------------- | ------------------------------- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDbPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your CosmosDB Private Endpoint, resides in.                                                                            |
| CosmosDbPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the CosmosDB Private Endpoint in.                                                                                               |
| CosmosDbPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The name of the subnet you want your CosmosDB's private endpoint to be in                                                                                     |
| CosmosDbPrivateEndpointGroupId               | <input type="checkbox" checked> | `Cassandra`                             | A private endpoint per databasetype is needed. Use `az network private-link-resource list` to fetch a list of possible group id's, or see the next paragraph. |
| DNSZoneResourceGroupName                     | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).                                                     |
| CosmosDbAccountPrivateDnsZoneName            | <input type="checkbox" checked> | `privatelink.documents.azure.com`       | The name of DNS zone where your private endpoint will be created in.                                                                                          |

## Group ID's

There are different settings for private endpoints for each CosmosDB type. This is the list at the time of writing (2021-09-30).

| Azure Cosmos account API type | Supported sub-resources (or group IDs) | Private zone name                      |
| ----------------------------- | -------------------------------------- | -------------------------------------- |
| Sql                           | Sql                                    | privatelink.documents.azure.com        |
| Cassandra                     | Cassandra                              | privatelink.cassandra.cosmos.azure.com |
| Mongo                         | MongoDB                                | privatelink.mongo.cosmos.azure.com     |
| Gremlin                       | Gremlin                                | privatelink.gremlin.cosmos.azure.com   |
| Gremlin                       | Sql                                    | privatelink.documents.azure.com        |
| Table                         | Table                                  | privatelink.table.cosmos.azure.com     |
| Table                         | Sql                                    | privatelink.documents.azure.com        |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create CosmosDB Account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Create-CosmosDbAccount.ps1"
    arguments: "-CosmosDbAccountName '$(CosmosDbAccountName)' -CosmosDbAccountResourceGroupName '$(CosmosDbAccountResourceGroupName)' -CosmosDbKind '$(CosmosDbKind)' -CosmosDbCapabilities '$(CosmosDbCapabilities)' -CosmosDbBackupIntervalInMinutes $(CosmosDbBackupIntervalInMinutes) -CosmosDbBackupRetentionInHours $(CosmosDbBackupRetentionInHours) -CosmosDbDefaultConsistencyLevel '$(CosmosDbDefaultConsistencyLevel)' -CosmosDbEnableAutomaticFailover $(CosmosDbEnableAutomaticFailover) -CosmosDbEnableMultipleWriteCosmosDbLocations $(CosmosDbEnableMultipleWriteCosmosDbLocations) -CosmosDbKeyvaultKeyUri '$(CosmosDbKeyvaultKeyUri)' -CosmosDbMaxStalenessInterval $(CosmosDbMaxStalenessInterval) -CosmosDbMaxStalenessPrefix $(CosmosDbMaxStalenessPrefix) -CosmosMongoDbServerVersion '$(CosmosMongoDbServerVersion)' -CosmosDbPrivateEndpointVnetName '$(CosmosDbPrivateEndpointVnetName)' -CosmosDbPrivateEndpointVnetResourceGroupName '$(CosmosDbPrivateEndpointVnetResourceGroupName)' -CosmosDbPrivateEndpointSubnetName '$(CosmosDbPrivateEndpointSubnetName)' -CosmosDbPrivateEndpointGroupId '$(CosmosDbPrivateEndpointGroupId)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -CosmosDbAccountPrivateDnsZoneName '$(CosmosDbAccountPrivateDnsZoneName)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -ResourceTags $(ResourceTags) -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Create-CosmosDbAccount.ps1)

# Links

[Azure CLI - az cosmosdb create](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_create)

[Azure CLI - az cosmosdb update](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_update)

[Azure CLI - az cosmosdb show](https://docs.microsoft.com/en-us/cli/azure/cosmosdb?view=azure-cli-latest#az_cosmosdb_show)

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_show)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)

[Azure - Monitor CosmosDb Resource Logs](https://docs.microsoft.com/en-us/azure/cosmos-db/cosmosdb-monitor-resource-logs)

[Azure - Metrics supported by Diagnostic Settings](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-supported#microsoftdocumentdbdatabaseaccounts)
