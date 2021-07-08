[[_TOC_]]

# Description

This snippet will remove the specified IP Range from the Azure SQL Server. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters

| Parameter                           | Required                        | Example Value                               | Description                                                                                                                                                                                                                                                           |
| ----------------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SqlServerResourceGroupName          | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the SQL Server is in                                                                                                                                                                                                                   |
| SqlServerName                       | <input type="checkbox" checked> | `somesqlserver$(Release.EnvironmentName)`   | The name for the SQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                                                                     |
| AccessRuleName                      | <input type="checkbox">         | `company hq`                                | You can delete an accessrule based on it's rulename. If you leave this empty, it will take the `CIDRToRemoveFromWhitelist` to delete the IP address/range.                                                                                                            |
| CIDRToRemoveFromWhitelist           | <input type="checkbox">         | `52.43.65.123/32`                           | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be removed from the whitelist. If you leave this value empty, it will use the machine's outbound `/32` ip (the machine where you are running this script from). |
| SubnetToRemoveSubnetName            | <input type="checkbox">         | `gateway2-subnet`                           | The name of the subnet you want to remove from the whitelist.                                                                                                                                                                                                         |
| SubnetToRemoveVnetName              | <input type="checkbox">         | `sp-dc-dev-001-vnet`                        | The vnetname of the subnet you want to remove from the whitelist.                                                                                                                                                                                                     |
| SubnetToRemoveVnetResourceGroupName | <input type="checkbox">         | `sharedservices-rg`                         | The VnetResourceGroupName your Vnet resides in.                                                                                                                                                                                                                       |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Remove Network Whitelist from Sql Server'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/SQL-Server/Remove-Network-Whitelist-from-Sql-Server.ps1'
               arguments: "-SqlServerName '$(SqlServerName)' -SqlServerResourceGroupName '$(SqlServerResourceGroupName)' -AccessRuleName '$(AccessRuleName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)' -SubnetToRemoveSubnetName '$(SubnetToRemoveSubnetName)' -SubnetToRemoveVnetName '$(SubnetToRemoveVnetName)' -SubnetToRemoveVnetResourceGroupName '$(SubnetToRemoveVnetResourceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/SQL-Server/Remove-IP-Whitelist-from-Sql-Server.ps1)

# Links

[Azure CLI - az sql server firewall-rule delete](https://docs.microsoft.com/en-us/cli/azure/sql/server/firewall-rule?view=azure-cli-latest#az_sql_server_firewall_rule_delete)
