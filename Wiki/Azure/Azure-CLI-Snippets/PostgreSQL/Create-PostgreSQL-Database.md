[[_TOC_]]

# Description

This snippet will create a PostgreSQL database on a specified existing PostgreSQL Server (Refer to [Create PostgreSQL Server](/Azure/Azure-CLI-Snippets/PostgreSQL/Create-PostgreSQL-Server) to create a SQL Server instance)

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                         | Example Value                               | Description                                                                                         |
| --------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| PostgreSqlServerResourceGroupName | `myteam-testapi-$(Release.EnvironmentName)` | The name of the Resource Group the PostgreSQL server was created                                    |
| PostgreSqlServerName              | `somesqlserver$(Release.EnvironmentName)`   | The name for the PostgreSQL Server resource. This has to be an existing PostgreSQL Server instance. |
| PostgreSqlDatabaseName            | `mydatabase`                                | The name for the PostgreSQL Database to create. Stick to alphanumerical and hyphens etc             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create PostgreSQL Database'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/PostgreSQL/Create-PostgreSQL-Database.ps1'
               arguments: "-PostgreSqlServerResourceGroupName '$(PostgreSqlServerResourceGroupName)' -PostgreSqlServerName '$(PostgreSqlServerName)' -PostgreSqlDatabaseName '$(PostgreSqlDatabaseName)'"
```

# Code

[Click here to download this script](../../../../src/PostgreSQL/Create-PostgreSQL-Database.ps1)

# Links

[Azure CLI - az postgres db create](https://docs.microsoft.com/en-us/cli/azure/postgres/db?view=azure-cli-latest#az_postgres_db_create)
