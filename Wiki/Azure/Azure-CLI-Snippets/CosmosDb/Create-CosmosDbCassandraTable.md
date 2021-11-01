[[_TOC_]]

# Description

This snippet will create a cassandra table inside an existing cassandra keyspace, within a CosmosDb account, if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                        | Required                        | Example Value                                                                                                                   | Description                                                                                                                                                                                                                                       |
| -------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDbAccountName              | <input type="checkbox" checked> | `somecosmosdb$(Release.EnvironmentName)`                                                                                        | The name for the CosmosDB Account resource. It's recommended to use just alphanumerical characters and hyphens.                                                                                                                                   |
| CosmosDbAccountResourceGroupName | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)`                                                                                     | The name of the resourcegroup you want your CosmosDB account to be created in                                                                                                                                                                     |
| CassandraKeySpaceName            | <input type="checkbox" checked> | `mykeyspacename`                                                                                                                | The name of the keyspace where the table will be created.                                                                                                                                                                                         |
| CassandraTableName               | <input type="checkbox" checked> | `mytable`                                                                                                                       | The name of the table to create.                                                                                                                                                                                                                  |
| CassandraTableSchema             | <input type="checkbox" checked> | `{'columns': [{'name': 'columnA','type': 'uuid'}, {'name': 'columnB','type': 'Ascii'}],'partitionKeys': [{'name': 'columnA'}]}` | The schema of the table in JSON.                                                                                                                                                                                                                  |
| CassandraTableThroughputType     | <input type="checkbox">         | `Autoscale` / `Manual`                                                                                                          | The throughput type you want to specify for your table. The options `Autoscale` and `Manual` are available.                                                                                                                                       |
| CassandraTableThroughputAmount   | <input type="checkbox">         | `4000`                                                                                                                          | The amount of RU's to specify per table. When choosing `Autoscale` the range has to be between `4000 - 1000000` with increments of `1000` RU's. When choosing `Manual` the range has to be between `400 - 1000000` with increments of `100` RU's. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Table in Cassandra Keyspace (CosmosDb)"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Create-CosmosDbCassandraTable.ps1"
    arguments: "-CosmosDbAccountName '$(CosmosDbAccountName)' -CosmosDbAccountResourceGroupName '$(CosmosDbAccountResourceGroupName)' -CassandraKeySpaceName '$(CassandraKeySpaceName)' -CassandraTableName '$(CassandraTableName)' -CassandraTableSchema '$(CassandraTableSchema)' -CassandraTableThroughputType '$(CassandraTableThroughputType)' -CassandraTableThroughputAmount '$(CassandraTableThroughputAmount)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Create-CosmosDbCassandraTable.ps1)

# Links

[Azure CLI - az cosmosdb cassandra table create](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/cassandra/table?view=azure-cli-latest#az_cosmosdb_cassandra_table_create)

[Azure CLI - az cosmosdb cassandra table migrate](https://docs.microsoft.com/nl-nl/cli/azure/cosmosdb/cassandra/table/throughput?view=azure-cli-latest#az_cosmosdb_cassandra_table_throughput_migrate)
