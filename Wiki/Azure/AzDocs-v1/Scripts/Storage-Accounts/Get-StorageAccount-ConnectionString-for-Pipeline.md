[[_TOC_]]

# Description

This snippet gets your storage connectionstring to be able to use it in a pipeline. You can set the pipeline variable name using the `OutputPipelineVariableName` parameter.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                       | Required                        | Example Value                           | Description                                                                                                                                                      |
| ------------------------------- | ------------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| StorageAccountResourceGroupName | <input type="checkbox" checked> | `My-Project-$(Release.EnvironmentName)` | The name of the resourcegroup where your storage account resides in.                                                                                             |
| StorageAccountName              | <input type="checkbox" checked> | `myredis-$(Release.EnvironmentName)`    | The name of your storage account.                                                                                                                                |
| OutputPipelineVariableName      | <input type="checkbox">         | `StorageAccountConnectionString`        | The name of the pipeline variable. This defaults to `StorageAccountConnectionString` and can be used inside the pipeline as `$(StorageAccountConnectionString)`. |

# Output

You can set the pipeline variable name using the `OutputPipelineVariableName` parameter. For example: if the `OutputPipelineVariableName` is `StorageAccountConnectionString`, you can use `$(StorageAccountConnectionString)` in your pipeline after running this script in your pipeline.

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  name: GetStorageAccountConnectionStringforPipeline
  displayName: "Get Storage Account ConnectionString for Pipeline"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/RedisCache/Get-StorageAccount-ConnectionString-for-Pipeline.ps1"
    arguments: "-StorageAccountName '$(StorageAccountName)' -StorageAccountResourceGroupName '$(StorageAccountResourceGroupName)' -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../src/RedisCache/Get-StorageAccount-ConnectionString-for-Pipeline.ps1)

# Links

[Azure CLI - az storage account show-connectionstring](https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az_storage_account_show_connection_string)
