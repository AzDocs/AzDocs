[[_TOC_]]

# Description

This snippet will give the appservice identity the permissions to read/write data from/to a SQL Database.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                   | Required                        | Example Value                               | Description                                                                                                                                                                                                                                                                                                                                                                                                           |
| --------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SqlServerResourceGroupName  | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup where the SQL server was created                                                                                                                                                                                                                                                                                                                                                        |
| SqlServerName               | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)`   | The name of the SQL Server to give permissions on                                                                                                                                                                                                                                                                                                                                                                     |
| SqlDatabaseName             | <input type="checkbox" checked> | `mydb`                                      | The name of the SQL Database to give permissions on                                                                                                                                                                                                                                                                                                                                                                   |
| ServiceUserEmail            | <input type="checkbox">         | `my_user@domain.com`                        | The emailaddress of the AAD user account to use. If you leave this empty, the currently logged in user will be used to login to SQL Server (this can be a Service Principal). Make sure this user is the AAD admin on the SQL Server (use the `Create-SQL-Server` script for this).                                                                                                                                   |
| ServiceUserObjectId         | <input type="checkbox">         | `ba7d0b10-3bfd-4d40-b6b4-a60b3476582f`      | The object ID of the AAD user account to use. See [Get ObjectID for ServiceUser](/Azure/AzDocs-v1/Scripts/Get-ObjectID-for-ServiceUser) for details how to retrieve this ObjectId. If you leave this empty, the currently logged in user will be used to login to SQL Server (this can be a Service Principal). Make sure this user is the AAD admin on the SQL Server (use the `Create-SQL-Server` script for this). |
| ServiceUserPassword         | <input type="checkbox">         | `Th15iSMyP@ssW0rD123!`                      | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc. If you leave this empty, the currently logged in user will be used to login to SQL Server (this can be a Service Principal). Make sure this user is the AAD admin on the SQL Server (use the `Create-SQL-Server` script for this).                                                                  |
| AppServiceName              | <input type="checkbox" checked> | `myappservice-$(Release.EnvironmentName)`   | The name of the AppService to give permissions for                                                                                                                                                                                                                                                                                                                                                                    |
| AppServiceResourceGroupName | <input type="checkbox" checked> | `myappservice-resourcegroup`                | The name of the resourcegroup of the AppService.                                                                                                                                                                                                                                                                                                                                                                      |
| AppServiceSlotName          | <input type="checkbox">         | `staging`                                   | OPTIONAL Name of the AppService slot to grand permissions to. If not defined. The default production slot will be used.                                                                                                                                                                                                                                                                                               |
| ApplyToAllSlots             | <input type="checkbox">         | `$false`                                    | Ability to grant permissions to all slots of the AppService. Default value is '$false'.                                                                                                                                                                                                                                                                                                                               |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Grant AppService dataread write ddladmin rights on SQL Server"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/SQL-Server/Grant-AppService-dataread-write-ddladmin-rights-on-SQL-Server.ps1"
    arguments: "-SqlServerResourceGroupName '$(SqlServerResourceGroupName)' -SqlServerName '$(SqlServerName)' -SqlDatabaseName '$(SqlDatabaseName)' -ServiceUserEmail '$(ServiceUserEmail)' -ServiceUserObjectId '$(ServiceUserObjectId)' -ServiceUserPassword '$(ServiceUserPassword)' -AppServiceName '$(AppServiceName)' -AppServiceResourceGroupName '$(AppServiceResourceGroupName)' -AppServiceSlotName '$(AppServiceSlotName)' -ApplyToAllSlots $(ApplyToAllSlots)"
```

# Code

[Click here to download this script](../../../../../src/SQL-Server/Grant-AppService-dataread-write-ddladmin-rights-on-SQL-Server.ps1)

# Links

[Azure CLI - az-sql-server-ad-admin-create](https://docs.microsoft.com/en-us/cli/azure/sql/server/ad-admin?view=azure-cli-latest#az-sql-server-ad-admin-create)

[Azure CLI - Secure Azure SQL Database connection from App Service using a managed identity](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-connect-msi)

[Azure CLI - az-login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

[Azure CLI - az-account-get-access-token](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-get-access-token)

[Azure CLI - az webapp deployment slot list](https://docs.microsoft.com/nl-nl/cli/azure/webapp/deployment/slot?view=azure-cli-latest#az_webapp_deployment_slot_list)
