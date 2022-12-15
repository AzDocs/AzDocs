[[_TOC_]]

# Description

This snippet will create a PostgreSQL Server if it does not exist within a given subnet. It will whitelist the application subnet so your app can connect to the SQL Server within the vnet. All the needed components (private endpoint, service endpoint etc) will be created too.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                           | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                       |
| ----------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PostgreSqlServerPassword            | <input type="checkbox" checked> | `#$mydatabas**e`                                                                                                                                | The password for the PostgreSql server username                                                                                                                                                                                                                                                                                                                                                                   |
| PostgreSqlServerUsername            | <input type="checkbox" checked> | `rob`                                                                                                                                           | The admin username for the PostgreSql server                                                                                                                                                                                                                                                                                                                                                                      |
| PostgreSqlServerName                | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)`                                                                                                       | The name for the PostgreSQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                                                                                                                                                                                                          |
| PostgreSqlServerResourceGroupName   | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                                                                                                     | The name of the resourcegroup you want your PostgreSql server to be created in                                                                                                                                                                                                                                                                                                                                    |
| PostgreSqlServerSku                 | <input type="checkbox" checked> | `GP_Gen5_2`                                                                                                                                     | The SKU to use for this server. This will determine the performancetier                                                                                                                                                                                                                                                                                                                                           |
| BackupRetentionInDays               | <input type="checkbox">         | `7`                                                                                                                                             | The number of days you want the backup retention to be                                                                                                                                                                                                                                                                                                                                                            |
| PostgreSqlServerVersion             | <input type="checkbox">         | `11`                                                                                                                                            | Define the version of postgresql to use. This defaults to v11                                                                                                                                                                                                                                                                                                                                                     |
| PostgreSqlServerPublicNetworkAccess | <input type="checkbox">         | `Enabled`/`Disabled`                                                                                                                            | Enable or disable the public endpoint. When using VNet Whitelisting this will forcefully be enabled. In this case the VNet whitelist will only allow access from your VNets via the public interface (this might be confusing). If you are ONLY using Private Endpoints, you can disable public access. The default value is set to `Disabled` with an forced override to `Enabled` if you use VNet whitelisting. |
| PostgreSqlServerMinimalTlsVersion   | <input type="checkbox">         | `TLS1_2`                                                                                                                                        | The possibility to enable a specific TLS version on your storage account. Defaults to TLS1_2.                                                                                                                                                                                                                                                                                                                     |
| LogAnalyticsWorkspaceResourceId     | <input type="checkbox" checked> | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The Log Analytics Workspace the diagnostic setting will be linked to.                                                                                                                                                                                                                                                                                                                                             |
| ForcePublic                         | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`).                                                                                                                                                                         |
| ForceDisableTLS                     | <input type="checkbox">         | n.a.                                                                                                                                            | If you are willingly creating a the resource without any TLS version enforce, you need to pass this boolean to confirm you want to do this. You can pass it as a switch without a value (`-ForceDisableTLS`)                                                                                                                                                                                                      |
| DiagnosticSettingsLogs              | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Logs'. By default, all categories for 'Logs' will be enabled.                                                                                                                                                                                                                                                                       |
| DiagnosticSettingsMetrics           | <input type="checkbox">         | `@('Requests';'MongoRequests';)`                                                                                                                | If you want to enable a specific set of diagnostic settings for the category 'Metrics'. By default, all categories for 'Metrics' will be enabled.                                                                                                                                                                                                                                                                 |
| DiagnosticSettingsDisabled          | <input type="checkbox">         | n.a.                                                                                                                                            | If you don't want to enable any diagnostic settings, you can pass this as a switch witout a value(`-DiagnosticsettingsDisabled`).                                                                                                                                                                                                                                                                                 |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                        | Description                                                         |
| -------------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------- |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in                           |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The name of the subnet the appservice is in                         |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                            | Required for Pvt Endpoint       | Example Value                               | Description                                                                                                                   |
| ---------------------------------------------------- | ------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| PostgreSqlServerPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                         | The ResourceGroup where your VNET, for your PostgreSQL Server Private Endpoint, resides in.                                   |
| PostgreSqlServerPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`        | The name of the VNET to place the PostgreSQL Server Private Endpoint in.                                                      |
| PostgreSqlServerPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                              | The name of the subnet you want your sql server's private endpoint to be in                                                   |
| DNSZoneResourceGroupName                             | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)`     | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).                     |
| PostgreSqlServerPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.postgres.database.windows.net` | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create PostgreSQL Server"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/PostgreSQL/Create-PostgreSQL-Server.ps1"
    arguments: "-PostgreSqlServerPassword '$(PostgreSqlServerPassword)' -PostgreSqlServerUsername '$(PostgreSqlServerUsername)' -PostgreSqlServerName '$(PostgreSqlServerName)' -PostgreSqlServerResourceGroupName '$(PostgreSqlServerResourceGroupName)' -PostgreSqlServerSku '$(PostgreSqlServerSku)' -BackupRetentionInDays '$(BackupRetentionInDays)' -PostgreSqlServerVersion '$(PostgreSqlServerVersion)' -PostgreSqlServerPublicNetworkAccess '$(PostgreSqlServerPublicNetworkAccess)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -PostgreSqlServerPrivateEndpointVnetResourceGroupName '$(PostgreSqlServerPrivateEndpointVnetResourceGroupName)' -PostgreSqlServerPrivateEndpointVnetName '$(PostgreSqlServerPrivateEndpointVnetName)' -PostgreSqlServerPrivateEndpointSubnetName '$(PostgreSqlServerPrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -PostgreSqlServerPrivateDnsZoneName '$(PostgreSqlServerPrivateDnsZoneName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -PostgreSqlServerMinimalTlsVersion '$(PostgreSqlServerMinimalTlsVersion)' -DiagnosticSettingsLogs $(DiagnosticSettingsLogs) -DiagnosticSettingsDisabled $(DiagnosticSettingsDisabled)"
```

# Code

[Click here to download this script](../../../../../src/PostgreSQL/Create-PostgreSQL-Server.ps1)

# Links

[Azure CLI - az network vnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_show)

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az postgres server create](https://docs.microsoft.com/en-us/cli/azure/postgres/server?view=azure-cli-latest#az_postgres_server_create)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az postgres server show](https://docs.microsoft.com/en-us/cli/azure/postgres/server?view=azure-cli-latest#az_postgres_server_show)

[Azure CLI - az network private-endpoint create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az network private-dns zone show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az network private-dns zone create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az network private-dns link vnet show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az network private-dns link vnet create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az network private-endpoint dns-zone-group create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az monitor diagnostic-settings-create](https://docs.microsoft.com/nl-nl/cli/azure/monitor/diagnostic-settings?view=azure-cli-latest#az_monitor_diagnostic_settings_create)
