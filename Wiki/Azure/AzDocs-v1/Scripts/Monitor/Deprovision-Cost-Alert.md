[[_TOC_]]

# Description

This snippet will deprovision a cost alert inside the subscription you're running this script from.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter  | Required                        | Example Value | Description                                      |
| ---------- | ------------------------------- | ------------- | ------------------------------------------------ |
| BudgetName | <input type="checkbox" checked> | `MyBudget`    | The name of the budget you would want to remove. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Deprovision Cost Alert"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Deprovision-Cost-Alert.ps1"
    arguments: "-BudgetName '$(BudgetName)'"
```

# Code

[Click here to download this script](../../../../../src/Monitor/Deprovision-Cost-Alert.ps1)

# Links

[Azure CLI - az consumption budget delete](https://docs.microsoft.com/en-us/cli/azure/consumption/budget?view=azure-cli-latest#az_consumption_budget_delete)
