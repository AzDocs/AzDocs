[[_TOC_]]

# Description

This snippet will list all the functions inside of your functionapp.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.
| Parameter | Required | Example Value | Description |
| ----------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------- |
| FunctionAppResourceGroupName | <input type="checkbox" checked> | `MyTeam-SomeApi-$(Release.EnvironmentName)` | The resourcegroup where the FunctionApp resides in. |
| FunctionAppName | <input type="checkbox" checked> | `FunctionApp-name` | Name of the FunctionApp to set the whitelist on. |
| FunctionTypesToReturn | <input type="checkbox" checked> | `serviceBusTrigger` | The type of function to return. Can be the following: `httpTrigger`, `serviceBusTrigger`, `orchestrationTrigger`, `activityTrigger`, `all`. Defaults to `all`. |
| FunctionValuetoReturn | <input type="checkbox" checked> | `functionNames` | The value to be returned. Can be the following: `all`, `functionNames`. Defaults to `all`. |
| OutputPipelineVariableName | <input type="checkbox"> | `FunctionList` | The variable name the value will be added to. Defaults to `FunctionList`. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "List all functions inside function app"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Functions/List-All-Functions-Inside-Function-App.ps1"
    arguments: >
      -FunctionAppResourceGroupName '$(FunctionAppResourceGroupName)' 
      -FunctionAppName '$(FunctionAppName)' 
      -FunctionTypesToReturn '$(FunctionTypesToReturn)'
      -FunctionValuetoReturn '$(FunctionValuetoReturn)'
      -OutputPipelineVariableName '$(OutputPipelineVariableName)'
```

# Code

[Click here to download this script](../../../../src/Functions/List-All-Functions-Inside-Function-App.ps1)

[Click here to find url for listing functions](https://github.com/projectkudu/kudu/wiki/Functions-API#listing-functions)
