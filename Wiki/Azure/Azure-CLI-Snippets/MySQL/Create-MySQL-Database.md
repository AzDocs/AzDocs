[[_TOC_]]

# Description

This snippet will create a MySQL Database if it does not exist. There needs to be an existing MySQL Server, so make sure you used the `Create-MySQL-Server` script before running this.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                    | Required                        | Example Value                               | Description                                                                                                         |
| ---------------------------- | ------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| MySqlServerResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your MySql server to be created in                                           |
| MySqlServerName              | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name for the MySQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc. |
| MySqlDatabaseName            | <input type="checkbox" checked> | `mydatabase`                                | The name of the MySQL database you want to create.                                                                  |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Create MySQL Database'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/MySQL/Create-MySQL-Database.ps1'
               arguments: "-MySqlServerResourceGroupName '$(MySqlServerResourceGroupName)' -MySqlServerName '$(MySqlServerName)' -MySqlDatabaseName '$(MySqlDatabaseName)'"
```

# Code

[Click here to download this script](../../../../src/MySQL/Create-MySQL-Database.ps1)

# Links

[Azure CLI - az mysql db create](https://docs.microsoft.com/en-us/cli/azure/mysql/db?view=azure-cli-latest#az_mysql_db_create)
