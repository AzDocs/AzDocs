[[_TOC_]]

# Description

This snippet will remove the specified IP Range from the Azure Cache for Redis. If you leave the `CIDRToRemoveFromWhitelist` parameter empty, it will use the outgoing IP from where you execute this script.

> NOTE: It is strongly suggested to set the condition, of this task in the pipeline, to always run. Even if your previous steps have failed. This is to avoid unintended whitelists whenever pipelines crash in the middle of something.

# Parameters

| Parameter                      | Required                        | Example Value                                 | Description                                                                                                                                                                                                                                                           |
| ------------------------------ | ------------------------------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RedisInstanceResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`   | The name of the resource group the Azure Cache for Redis is in.                                                                                                                                                                                                       |
| RedisInstanceName              | <input type="checkbox" checked> | `someredisinstance$(Release.EnvironmentName)` | The name for the Azure Cache for Redis resource.                                                                                                                                                                                                                      |
| AccessRuleName                 | <input type="checkbox">         | `company hq`                                  | You can delete an accessrule based on it's rulename. If you leave this empty, it will take the `CIDRToRemoveFromWhitelist` to delete the IP address/range.                                                                                                            |
| CIDRToRemoveFromWhitelist      | <input type="checkbox">         | `52.43.65.123/32`                             | IP range in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation that should be removed from the whitelist. If you leave this value empty, it will use the machine's outbound `/32` ip (the machine where you are running this script from). |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
        - task: AzureCLI@2
           displayName: 'Remove Network Whitelist from RedisCache'
           condition: always()
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/RedisCache/Remove-Network-Whitelist-from-RedisCache.ps1'
               arguments: "-RedisInstanceName '$(RedisInstanceName)' -RedisInstanceResourceGroupName '$(RedisInstanceResourceGroupName)' -AccessRuleName '$(AccessRuleName)' -CIDRToRemoveFromWhitelist '$(CIDRToRemoveFromWhitelist)'"
```

# Code

[Click here to download this script](../../../../src/RedisCache/Remove-IP-Whitelist-from-RedisCache.ps1)

# Links

[Azure CLI - az redis firewall-rules list](https://docs.microsoft.com/en-us/cli/azure/redis/firewall-rules?view=azure-cli-latest#az_redis_firewall_rules_list)

[Azure CLI - az redis firewall-rules delete](https://docs.microsoft.com/en-us/cli/azure/redis/firewall-rules?view=azure-cli-latest#az_redis_firewall_rules_delete)
