[[_TOC_]]

# Description

This snippet gets your Redis Cache connectionstring to be able to use it in a pipeline. You can set the pipeline variable name using the `OutputPipelineVariableName` parameter.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                        | Required                        | Example Value                           | Description                                                                                                                                                                                                                                                      |
| -------------------------------- | ------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RedisInstanceResourceGroupName   | <input type="checkbox" checked> | `My-Project-$(Release.EnvironmentName)` | The name of the resourcegroup where your RedisCache instance resides in.                                                                                                                                                                                         |
| RedisInstanceName                | <input type="checkbox" checked> | `myredis-$(Release.EnvironmentName)`    | The name of your RedisCache instance.                                                                                                                                                                                                                            |
| ForceUseInsecureNonSslConnection | <input type="checkbox">         | n.a.                                    | By default the SSL connection is used. You can set this bool to `$true` if you want to force using the non-SSL connectionstring. We strongly recommend using the SSL version. You can pass it as a switch without a value (`-ForceUseInsecureNonSslConnection`). |
| OutputPipelineVariableName       | <input type="checkbox">         | `RedisConnectionString`                 | The name of the pipeline variable. This defaults to `RedisConnectionString` and can be used inside the pipeline as `$(RedisConnectionString)`.                                                                                                                   |

# Output

You can set the pipeline variable name using the `OutputPipelineVariableName` parameter. For example: if the `OutputPipelineVariableName` is `RedisConnectionString`, you can use `$(RedisConnectionString)` in your pipeline after running this script in your pipeline.

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  name: GetRedisCacheConnectionStringforPipeline
  displayName: "Get RedisCache ConnectionString for Pipeline"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/RedisCache/Get-RedisCache-ConnectionString-for-Pipeline.ps1"
    arguments: "-RedisInstanceResourceGroupName '$(RedisInstanceResourceGroupName)' -RedisInstanceName '$(RedisInstanceName)' -ForceUseInsecureNonSslConnection $false -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../src/RedisCache/Get-RedisCache-ConnectionString-for-Pipeline.ps1)

# Links

[Azure CLI - az redis list-keys](https://docs.microsoft.com/en-us/cli/azure/redis?view=azure-cli-latest#az_redis_list_keys)

[Azure CLI - az redis show](https://docs.microsoft.com/en-us/cli/azure/redis?view=azure-cli-latest#az_redis_show)
