[[_TOC_]]

# Description

This snippet will create a cassandra keyspace inside an existing CosmosDB account if it does not exist.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                        | Required                        | Example Value                               | Description                                                                                                     |
| -------------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| CosmosDbAccountName              | <input type="checkbox" checked> | `somecosmosdb$(Release.EnvironmentName)`    | The name for the CosmosDB Account resource. It's recommended to use just alphanumerical characters and hyphens. |
| CosmosDbAccountResourceGroupName | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name of the resourcegroup you want your CosmosDB account to be created in                                   |
| CassandraKeySpaceName            | <input type="checkbox" checked> | `mykeyspacename`                            | The name of the keyspace to create.                                                                             |

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
    arguments: "-CosmosDbAccountName '$(CosmosDbAccountName)' -CosmosDbAccountResourceGroupName '$(CosmosDbAccountResourceGroupName)' -CassandraKeySpaceName '$(CassandraKeySpaceName)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Create-CosmosDbCassandraKeyspace.ps1)

# Links

[Azure CLI - az cosmosdb cassandra keyspace create](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/cassandra/keyspace?view=azure-cli-latest#az_cosmosdb_cassandra_keyspace_create)
