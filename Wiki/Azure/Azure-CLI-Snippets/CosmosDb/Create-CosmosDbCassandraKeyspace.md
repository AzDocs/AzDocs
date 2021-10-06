[[_TOC_]]

# Description

This snippet will create a cassandra keyspace inside an existing CosmosDB account if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                         | Required                        | Example Value                               | Description                                                                                                                                                                                                                                          |
| --------------------------------- | ------------------------------- | ------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDbAccountName               | <input type="checkbox" checked> | `somecosmosdb$(Release.EnvironmentName)`    | The name for the CosmosDB Account resource. It's recommended to use just alphanumerical characters and hyphens.                                                                                                                                      |
| CosmosDbAccountResourceGroupName  | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name of the resourcegroup you want your CosmosDB account to be created in                                                                                                                                                                        |
| CassandraKeySpaceName             | <input type="checkbox" checked> | `mykeyspacename`                            | The name of the keyspace to create.                                                                                                                                                                                                                  |
| CassandraKeyspaceThroughputType   | <input type="checkbox">         | `Autoscale` / `Manual`                      | The throughput type you want to specify for your keyspace. The options `Autoscale` and `Manual` are available.                                                                                                                                       |
| CassandraKeyspaceThroughputAmount | <input type="checkbox">         | `4000`                                      | The amount of RU's to specify per keyspace. When choosing `Autoscale` the range has to be between `4000 - 1000000` with increments of `1000` RU's. When choosing `Manual` the range has to be between `400 - 1000000` with increments of `100` RU's. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Keyspace in CosmosDB Account"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Create-CosmosDbCassandraKeyspace.ps1"
    arguments: "-CosmosDbAccountName '$(CosmosDbAccountName)' -CosmosDbAccountResourceGroupName '$(CosmosDbAccountResourceGroupName)' -CassandraKeySpaceName '$(CassandraKeySpaceName)' -CassandraKeyspaceThroughputType '$(CassandraKeyspaceThroughputType)' -CassandraKeyspaceThroughputAmount '$(CassandraKeyspaceThroughputAmount)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Create-CosmosDbCassandraKeyspace.ps1)

# Links

[Azure CLI - az cosmosdb cassandra keyspace create](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/cassandra/keyspace?view=azure-cli-latest#az_cosmosdb_cassandra_keyspace_create)

[Azure CLI - az cosmosdb cassandra keyspace throughput migrate](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/cassandra/keyspace/throughput?view=azure-cli-latest#az_cosmosdb_cassandra_keyspace_throughput_migrate)
