[[_TOC_]]

# Description

This snippet will create a SQL Server if it does not exist. It will also enable auditlogging towards LogAnalyticsWorkspace. Optionally it will enable Azure AD Admin support if you pass the parameters for it.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                                         | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SqlServerPassword                                 | <input type="checkbox" checked> | `#$mydatabas**e`                                                                                                                                | The password for the sqlserverusername                                                                                                                                                                                                                                                                                                                               |
| SqlServerUsername                                 | <input type="checkbox" checked> | `rob`                                                                                                                                           | The admin username for the sqlserver                                                                                                                                                                                                                                                                                                                                 |
| SqlServerName                                     | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)`                                                                                                       | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                                                                                                                                                                    |
| SqlServerResourceGroupName                        | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                                                                                                     | The name of the resourcegroup you want your sql server to be created in                                                                                                                                                                                                                                                                                              |
| SqlServerMinimalTlsVersion                        | <input type="checkbox">         | `1.2`                                                                                                                                           | The minimal TLS version to use. Defaults to `1.2`. Options are `1.0`, `1.1`, `1.2`                                                                                                                                                                                                                                                                                   |
| LogAnalyticsWorkspaceResourceId                   | <input type="checkbox">         | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace to write the auditing logs to for this SQL Server instance                                                                                                                                                                                                                                                                               |
| SqlServerEnablePublicNetwork                      | <input type="checkbox">         | `true`/`false`                                                                                                                                  | Enable/disable public access. <font color="red">NOTE:</font> If you use vnet whitelisting, this should be enabled. If you use private endpoints you can disable this.                                                                                                                                                                                                |
| SqlServerAzureAdAdminObjectId                     | <input type="checkbox">         | `808380fc-c267-4e74-a3b3-d9b57ba39800`                                                                                                          | Use in combination with the `SqlServerAzureAdAdminDisplayName` parameter. Pass the `object id` of the Azure AD user to make admin. You can fetch this `object id` using the `az ad user show` command. If you just want to use the current executing service principal as AAD Admin for SQL Server, use the `MakeCurrentServicePrincipalSqlServerAzureAdAdmin` flag. |
| SqlServerAzureAdAdminDisplayName                  | <input type="checkbox">         | `myuser@company.com`                                                                                                                            | Use in combination with the `SqlServerAzureAdAdminObjectId` parameter. The name/email of the Azure AD user to make SQL Server Admin. If you just want to use the current executing service principal as AAD Admin for SQL Server, use the `MakeCurrentServicePrincipalSqlServerAzureAdAdmin` flag.                                                                   |
| MakeCurrentServicePrincipalSqlServerAzureAdAdmin  | <input type="checkbox">         | `$true`/`$false`                                                                                                                                | Make the script executing service principal admin for this SQL Server (this enables AAD Admin on the SQL Server). If you want to specify another account, use the `SqlServerAzureAdAdminObjectId` and `SqlServerAzureAdAdminDisplayName` parameters.                                                                                                                 |
| GrantSqlServerManagedIdentityDirectoryReadersRole | <input type="checkbox">         | `$true`/`$false`                                                                                                                                | Enabling this will result in the SQL Server managed identity having the `Directory readers` role in AAD. This means that the executing user/service principal should have the permission to manage permissions in AAD.                                                                                                                                               |
| UserAssignedManagedIdentityResourceId             | <input type="checkbox">         | `/subscriptions/<subscriptionId>/resourceGroups/<rgName>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<MIName>`                   | Assign a user created managed identity to this SQL server. This is handy if you have one predefined MI with the `Directory Readers` role (Whenever you don't have the permissions to change something in AAD yourself).                                                                                                                                              |
| ForcePublic                                       | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`).                                                                                                                            |

# VNET Whitelisting Parameters

If you want to use "vnet whitelisting" on your resource. Use these parameters. Using VNET Whitelisting is the recommended way of building & connecting your application stack within Azure.

> NOTE: These parameters are only required when you want to use the VNet whitelisting feature for this resource.

| Parameter                        | Required for VNET Whitelisting  | Example Value                        | Description                                                         |
| -------------------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------- |
| ApplicationVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET, for your appservice, resides in. |
| ApplicationVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET the appservice is in                           |
| ApplicationSubnetName            | <input type="checkbox" checked> | `app-subnet-4`                       | The name of the subnet the appservice is in                         |

# Private Endpoint Parameters

If you want to use private endpoints on your resource. Use these parameters. Private Endpoints are used for connecting to your Azure Resources from on-premises.

> NOTE: These parameters are only required when you want to use a private endpoint for this resource.

| Parameter                                     | Required for Pvt Endpoint       | Example Value                           | Description                                                                                                                   |
| --------------------------------------------- | ------------------------------- | --------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| SqlServerPrivateEndpointVnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                     | The ResourceGroup where your VNET, for your SQL Server Private Endpoint, resides in.                                          |
| SqlServerPrivateEndpointVnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`    | The name of the VNET to place the SQL Server Private Endpoint in.                                                             |
| SqlServerPrivateEndpointSubnetName            | <input type="checkbox" checked> | `app-subnet-3`                          | The name of the subnet you want your sql server's private endpoint to be in                                                   |
| DNSZoneResourceGroupName                      | <input type="checkbox" checked> | `MyDNSZones-$(Release.EnvironmentName)` | Make sure to use the shared DNS Zone resource group (you can only register a zone once per subscription).                     |
| SqlServerPrivateDnsZoneName                   | <input type="checkbox" checked> | `privatelink.database.windows.net`      | The name of DNS zone where your private endpoint will be created in. If you are unsure use `privatelink.database.windows.net` |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create SQL Server"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/SQL-Server/Create-SQL-Server.ps1"
    arguments: "-SqlServerPassword '$(SqlServerPassword)' -SqlServerUsername '$(SqlServerUsername)' -SqlServerName '$(SqlServerName)' -SqlServerResourceGroupName '$(SqlServerResourceGroupName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -SqlServerMinimalTlsVersion '$(SqlServerMinimalTlsVersion)' -SqlServerEnablePublicNetwork '$(SqlServerEnablePublicNetwork)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -SqlServerPrivateEndpointVnetResourceGroupName '$(SqlServerPrivateEndpointVnetResourceGroupName)' -SqlServerPrivateEndpointVnetName '$(SqlServerPrivateEndpointVnetName)' -SqlServerPrivateEndpointSubnetName '$(SqlServerPrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -SqlServerPrivateDnsZoneName '$(SqlServerPrivateDnsZoneName)' -SqlServerAzureAdAdminObjectId '$(SqlServerAzureAdAdminObjectId)' -SqlServerAzureAdAdminDisplayName '$(SqlServerAzureAdAdminDisplayName)' -MakeCurrentServicePrincipalSqlServerAzureAdAdmin $(MakeCurrentServicePrincipalSqlServerAzureAdAdmin)"
```

# Code

[Click here to download this script](../../../../src/SQL-Server/Create-SQL-Server.ps1)

# Links

[Azure CLI - az-network-private-link-resource-list](https://docs.microsoft.com/en-us/cli/azure/network/private-link-resource?view=azure-cli-latest#az-network-private-link-resource-list)

[Azure CLI - az-sql-server-create](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-create)

[Azure CLI - az-network-vnet-subnet-update](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-update)

[Azure CLI - az-sql-server-show](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-show)

[Azure CLI - az-network-private-endpoint-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#az-network-private-endpoint-create)

[Azure CLI - az-network-private-dns-zone-show](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-show)

[Azure CLI - az-network-private-dns-zone-create](https://docs.microsoft.com/en-us/cli/azure/ext/privatedns/network/private-dns/zone?view=azure-cli-latest#ext-privatedns-az-network-private-dns-zone-create)

[Azure CLI - az-network-private-dns-link-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-show)

[Azure CLI - az-network-private-dns-link-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/private-dns/link/vnet?view=azure-cli-latest#az-network-private-dns-link-vnet-create)

[Azure CLI - az-network-private-endpoint-dns-zone-group-create](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint/dns-zone-group?view=azure-cli-latest#az-network-private-endpoint-dns-zone-group-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)

[Azure CLI - az-sql-server-vnet-rule-create](https://docs.microsoft.com/en-us/cli/azure/sql/server/vnet-rule?view=azure-cli-latest#az-sql-server-vnet-rule-create)

[Azure CLI - az-sql-server-update](https://docs.microsoft.com/en-us/cli/azure/sql/server?view=azure-cli-latest#az-sql-server-update)
