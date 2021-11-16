[[_TOC_]]

# Description

This snippet will add an elastic pool to an existing SQL Server instance. When creating an elastic pool you have different options to specify capacity: DTU and VCore. The underlying service is the same, but this has to do with how your service is billed and how your databases are allocated.

## DTU

When using the DTU (Database Transaction Unit) model when creating an elastic pool, you pay one fixed price for your IO/Memory/Storage and backup retention. This option is simpler when you're setting up simple databases.

The editions you can pick from: 'Basic', 'Standard' and 'Premium'. To understand which options you have per edition, see: [Azure - DTU limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-dtu-elastic-pools)

## VCore

When using the VCore (Virtual Core) model when creating an elastic pool, you pay separately for your compute and seperate for your storage. This option is useful when you want to have more insight and flexibility in managing costs.

The editions you can pick from: 'GeneralPurpose', 'BusinessCritical'. To understand which options you have per edition, see [Azure - VCore limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)

It is always possible to switch from the one to the other during your development cycle.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                         | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                            |
| --------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ElasticPoolName                   | <input type="checkbox" checked> | `my-elastic-pool`                                                                                                                               | The name of the elastic pool.                                                                                                                                          |
| SqlServerResourceGroupName        | <input type="checkbox" checked> | `my-sql-server-resource-group`                                                                                                                  | The resourcegroup where your sql server resides in for which you're making an elastic pool.                                                                            |
| SqlServerName                     | <input type="checkbox" checked> | `mysqlserver`                                                                                                                                   | The name of the SQL Server resource.                                                                                                                                   |
| ElasticPoolEdition                | <input type="checkbox">         | `Standard`                                                                                                                                      | The elastic pool edition. When using DTU's pick from: 'Basic', 'Standard' and 'Premium'. When working with VCores, pick from: 'GeneralPurpose' and 'BusinessCritical'. |
| ElasticPoolCapacity               | <input type="checkbox">         | `50`                                                                                                                                            | The capacity of the pool in DTU's or VCores.                                                                                                                           |
| ElasticPoolMaxCapacityPerDatabase | <input type="checkbox">         | `20`                                                                                                                                            | The max capacity in DTU's or VCores any one database in the pool can consume.                                                                                          |
| ElasticPoolMinCapacityPerDatabase | <input type="checkbox">         | `10`                                                                                                                                            | The minimum capacity in DTU's or VCores each database in the pool is guaranteed.                                                                                       |
| ElasticPoolVCoreFamily            | <input type="checkbox">         | `Gen5`                                                                                                                                          | The compute generation component when using VCores. You can pick from: 'Gen5' and 'Gen4'.                                                                              |
| ElasticPoolMaxStorageSize         | <input type="checkbox">         | `20GB`                                                                                                                                          | The max storage size.                                                                                                                                                  |
| ElasticPoolZoneRedundancy         | <input type="checkbox">         | `true` \ `false`                                                                                                                                | To enable zone redundancy for the pool. NOTE: Not for all editions zone redundancy can be enabled.                                                                     |
| LogAnalyticsWorkspaceResourceId   | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                  |
| DiagnosticSettingsLogs            | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                            |
| DiagnosticSettingsMetrics         | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                      |
| DiagnosticSettingsDisabled        | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                      |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Elastic Pool to SQL Server"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/SQL-Server/Add-Elastic-Pool-To-SQL-Server.ps1"
    arguments: "-ElasticPoolName '$(ElasticPoolName)' -SqlServerResourceGroupName '$(SqlServerResourceGroupName)' -SqlServerName '$(SqlServerName)' -ElasticPoolEdition '$(ElasticPoolEdition)' -ElasticPoolCapacity '$(ElasticPoolCapacity)' -ElasticPoolMaxCapacityPerDatabase '$(ElasticPoolMaxCapacityPerDatabase)' -ElasticPoolMinCapacityPerDatabase '$(ElasticPoolMinCapacityPerDatabase)' -ElasticPoolVCoreFamily '$(ElasticPoolVCoreFamily)' -ElasticPoolMaxStorageSize '$(ElasticPoolMaxStorageSize)' -ElasticPoolZoneRedundancy '$(ElasticPoolZoneRedundancy)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -ResourceTags $(ResourceTags) -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../src/SQL-Server/Add-Elastic-Pool-To-SQL-Server.ps1)

# Links

[Azure - DTU limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-dtu-elastic-pools)

[Azure - VCore limits for elastic pools](https://docs.microsoft.com/en-us/azure/azure-sql/database/resource-limits-vcore-elastic-pools)

[Azure CLI - az sql elastic-pool create](https://docs.microsoft.com/en-us/cli/azure/sql/elastic-pool?view=azure-cli-latest#az_sql_elastic_pool_create)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)
