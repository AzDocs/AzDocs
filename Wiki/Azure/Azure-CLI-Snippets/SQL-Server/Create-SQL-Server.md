[[_TOC_]]

# Description

This snippet will create a SQL Server if it does not exist. There are two options of connecting your application to this SQL Server.

## VNET Whitelisting (uses the "public interface")

Microsoft does some neat tricks where you can whitelist your vnet/subnet op the SQL server without your sql server having to be inside the vnet itself (public/private address translation).
This script will whitelist the application subnet so your app can connect to the SQL Server over the public endpoint, while blocking all other traffic (internet traffic for example). Service Endpoints will also be provisioned if needed on the subnet.

## Private Endpoints

There is an option where it will create private endpoints for you & also disables public access if desired. All the needed components (private endpoint, DNS etc.) will be created too.

IMPORTANT NOTE: If you use the EnableSqlServerAuditing option, make sure to enable the `Access service principal details in script` checkbox in the Azure CLI step in your Azure DevOps pipeline. This is needed for the last few lines of script which are built in Azure PowerShell (Azure PowerShell needs to login separate to the Azure CLI).

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                       | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                                                                                                               |
| ------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SqlServerSubscriptionId         | <input type="checkbox" checked> | `2cf65221-ba2c-42ba-987b-ef8981519431`                                                                                                          | The subscription ID (or name) on which the SQL Server should be provisioned.                                                                                                                                                              |
| SqlServerPassword               | <input type="checkbox" checked> | `#$mydatabas**e`                                                                                                                                | The password for the sqlserverusername                                                                                                                                                                                                    |
| SqlServerUsername               | <input type="checkbox" checked> | `rob`                                                                                                                                           | The admin username for the sqlserver                                                                                                                                                                                                      |
| SqlServerName                   | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)`                                                                                                       | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                                         |
| SqlServerResourceGroupName      | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                                                                                                     | The name of the resourcegroup you want your sql server to be created in                                                                                                                                                                   |
| SqlServerMinimalTlsVersion      | <input type="checkbox">         | `1.2`                                                                                                                                           | The minimal TLS version to use. Defaults to `1.2`. Options are `1.0`, `1.1`, `1.2`                                                                                                                                                        |
| LogAnalyticsWorkspaceResourceId | <input type="checkbox">         | `/subscriptions/<subscriptionid>/resourceGroups/<resourcegroup>/providers/Microsoft.OperationalInsights/workspaces/<loganalyticsworkspacename>` | The log analytics workspace to write the auditing logs to for this SQL Server instance                                                                                                                                                    |
| SqlServerEnablePublicNetwork    | <input type="checkbox">         | `true`/`false`                                                                                                                                  | Enable/disable public access. <font color="red">NOTE:</font> If you use vnet whitelisting, this should be enabled. If you use private endpoints you can disable this.                                                                     |
| ForcePublic                     | <input type="checkbox">         | n.a.                                                                                                                                            | If you are not using any networking settings, you need to pass this boolean to confirm you are willingly creating a public resource (to avoid unintended public resources). You can pass it as a switch without a value (`-ForcePublic`). |

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
           displayName: 'Create SQL Server'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               addSpnToEnvironment: True
               scriptPath: '$(Pipeline.Workspace)/AzDocs/SQL-Server/Create-SQL-Server.ps1'
               arguments: "-SqlServerSubscriptionId '$(SqlServerSubscriptionId)' -SqlServerPassword '$(SqlServerPassword)' -SqlServerUsername '$(SqlServerUsername)' -SqlServerName '$(SqlServerName)' -SqlServerResourceGroupName '$(SqlServerResourceGroupName)' -LogAnalyticsWorkspaceResourceId '$(LogAnalyticsWorkspaceResourceId)' -SqlServerMinimalTlsVersion '$(SqlServerMinimalTlsVersion)' -SqlServerEnablePublicNetwork '$(SqlServerEnablePublicNetwork)' -ApplicationVnetResourceGroupName '$(ApplicationVnetResourceGroupName)' -ApplicationVnetName '$(ApplicationVnetName)' -ApplicationSubnetName '$(ApplicationSubnetName)' -SqlServerPrivateEndpointVnetResourceGroupName '$(SqlServerPrivateEndpointVnetResourceGroupName)' -SqlServerPrivateEndpointVnetName '$(SqlServerPrivateEndpointVnetName)' -SqlServerPrivateEndpointSubnetName '$(SqlServerPrivateEndpointSubnetName)' -DNSZoneResourceGroupName '$(DNSZoneResourceGroupName)' -SqlServerPrivateDnsZoneName '$(SqlServerPrivateDnsZoneName)'"
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
