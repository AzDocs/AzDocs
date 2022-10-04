[[_TOC_]]

# Description

This snippet will return the primary connectionstring for a cosmosDb account. 

# Parameters

| Parameter                              | Required                        | Example Value                               | Description                                                                                                                                                                                                                   |
| -------------------------------------- | ------------------------------- | ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CosmosDBAccountName                    | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name for the CosmosDb account resource. It's recommended to use just alphanumerical characters without hyphens etc.                                                                                                       |
| CosmosDBAccountResourceGroupName       | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resource group the CosmosDb account is in.                                                                                                                                                               |
| OutputPipelineVariableName                        | <input type="checkbox">         | `my-pipeline-variable`                           | The name of the pipeline variable. Defaults to 'CosmosDbConnectionString'. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Get CosmosDb connection-string"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CosmosDb/Get-CosmosDb-Connectionstring.ps1"
    arguments: "-CosmosDBAccountName '$(CosmosDBAccountName)' -CosmosDBAccountResourceGroupName '$(CosmosDBAccountResourceGroupName)' -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../src/CosmosDb/Get-CosmosDb-Connectionstring.ps1)

# Links

[Azure CLI - az cosmosdb keys list](https://docs.microsoft.com/en-us/cli/azure/cosmosdb/keys?view=azure-cli-latest)
