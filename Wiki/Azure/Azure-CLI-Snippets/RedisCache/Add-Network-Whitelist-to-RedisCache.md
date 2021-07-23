[[_TOC_]]

# Description

This snippet will whitelist the specified IP Range from the Azure Cache for Redis. If you leave the `CIDRToWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

# Parameters

| Parameter                      | Required                        | Example Value                                 | Description                                                                                                                                                                                                                               |
| ------------------------------ | ------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RedisInstanceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`   | The name of the resource group the Azure Cache for Redis is in.                                                                                                                                                                           |
| RedisInstanceName              | <input type="checkbox" checked> | `someredisinstance$(Release.EnvironmentName)` | The name for the Azure Cache for Redis resource.                                                                                                                                                                                          |
| AccessRuleName                 | <input type="checkbox">         | `companyhq`                                   | You can override the name for this accessrule. If you leave this empty, the `CIDRToWhitelist` will be used for the naming (automatically). We recommend to leave this empty for ephemeral whitelists like Azure DevOps Hosted Agent ip's. |
| CIDRToWhitelist                | <input type="checkbox">         | `52.43.65.123/32`                             | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be whitelisted. If you leave this value empty, it will whitelist the machine's ip where you're running the script from.             |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Add Network Whitelist to RedisCache'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/RedisCache/Add-Network-Whitelist-to-RedisCache.ps1'
               arguments: "-RedisInstanceName '$(RedisInstanceName)' -RedisInstanceResourceGroupName '$(RedisInstanceResourceGroupName)' -AccessRuleName '$(AccessRuleName)' -CIDRToWhitelist '$(CIDRToWhitelist)'"
```

# Code

[Click here to download this script](../../../../src/RedisCache/Add-IP-Whitelist-to-RedisCache.ps1)

# Links

[Azure CLI - az redis firewall-rules list](https://docs.microsoft.com/en-us/cli/azure/redis/firewall-rules?view=azure-cli-latest#az_redis_firewall_rules_list)

[Azure CLI - az redis firewall-rules create](https://docs.microsoft.com/en-us/cli/azure/redis/firewall-rules?view=azure-cli-latest#az_redis_firewall_rules_create)
