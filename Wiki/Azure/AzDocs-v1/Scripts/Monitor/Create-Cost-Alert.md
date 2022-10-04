[[_TOC_]]

# Description

This snippet will create a cost alert.

The following parameters cannot be updated: `BudgetTimeGrain` and `BudgetStartDate`. If you want to update these values, please remove the existing budget and create a new one.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                  | Required                        | Example Value                                                                                                                         | Description                                                                                                                                                                                                             |
| -------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BudgetResourceGroupScope   | <input type="checkbox">         | `myrg$(Release.EnvironmentName)`                                                                                                      | OPTIONAL: The name of the resourcegroup you want to scope this budget to. If you leave this empty, it will either use the current subscription scope or the managementgroup (when filled `BudgetManagementGroupScope`). |
| BudgetManagementGroupScope | <input type="checkbox">         | `MyManagementGroup`                                                                                                                   | OPTIONAL: The name of the managementgroup you want to scope this budget to. If you leave this empty, it will either use the current subscription scope or the resourcegroup (when filled `BudgetResourceGroupScope`).   |
| BudgetName                 | <input type="checkbox" checked> | `MyBudget`                                                                                                                            | The name you want to use for this budget.                                                                                                                                                                               |
| BudgetAmount               | <input type="checkbox" checked> | `1234`                                                                                                                                | The amount of this budget in your default currency (euro's or dollars for example).                                                                                                                                     |
| BudgetTimeGrain            | <input type="checkbox">         | `BillingMonthly.`                                                                                                                     | The timegrain for this budget. The options are `Annually`, `BillingAnnual`, `BillingMonth`, `BillingQuarter`, `Monthly`, `Quarterly`. This defaults to `BillingMonth`.                                                  |
| BudgetStartDate            | <input type="checkbox">         | `2021-11-01`                                                                                                                          | The startdate for this budget. This has to be the first of the month. This defaults to the first of the current month.                                                                                                  |
| BudgetEndDate              | <input type="checkbox">         | `2031-11-01`                                                                                                                          | The enddate for this budget. This defaults to the first of the current month + 10 years.                                                                                                                                |
| AlertThresholdType         | <input type="checkbox">         | `Forecasted`                                                                                                                          | The type of alert you want. The options are `Forecasted`, `Actual`. Defaults to `Forecasted`.                                                                                                                           |
| AlertThresholdOperator     | <input type="checkbox">         | `GreaterThan`                                                                                                                         | The operator for your alert. Options are `EqualTo`, `GreaterThan`, `GreaterThanOrEqualTo`. Defaults to `GreaterThan`.                                                                                                   |
| AlertThreshold             | <input type="checkbox">         | `85`                                                                                                                                  | The threshold when to alert in percentages. So with `85` it will send you an alert at 85% of the budget. This defaults to `85`.                                                                                         |
| AlertContactEmails         | <input type="checkbox">         | `@('my.user@company.com'; 'another.user@mycompany.com')`                                                                              | A list of emailadresses to send the notification to when the threshold is exceeded. At least either `AlertContactEmails`, `AlertContactRoles` or `AlertContactActionGroups` should be filled (one or more).             |
| AlertContactRoles          | <input type="checkbox">         | `@('SomeRole'; 'AnotherRole')`                                                                                                        | Send alerts to everyone in the defined roles. At least either `AlertContactEmails`, `AlertContactRoles` or `AlertContactActionGroups` should be filled (one or more).                                                   |
| AlertContactActionGroups   | <input type="checkbox">         | `@('/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>/providers/microsoft.insights/actionGroups/<actionGroupName>')` | Send notifications to these actions groups. At least either `AlertContactEmails`, `AlertContactRoles` or `AlertContactActionGroups` should be filled (one or more).                                                     |
| Filters                    | <input type="checkbox">         | `@{ and = @( @{ tags = @{ name = "teamname"; operator = "In"; values = @("myteamname") } } ) }`                                       | Allows you to control the filters in a finegrained manner. You can alternatively use `FilterOnTagName` and `FilterOnTagValue` for simply filtering on one tag.                                                          |
| FilterOnTagName            | <input type="checkbox">         | `teamname`                                                                                                                            | Filter on this tagname (Fill FilterOnTagValue with the value to filter this tag on). Alternatively use `Filters` to define your own filters.                                                                            |
| FilterOnTagValue           | <input type="checkbox">         | `teamname`                                                                                                                            | Filter on this tagvalue (Fill FilterOnTagName for the tagname to filter on). Alternatively use `Filters` to define your own filters.                                                                                    |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Cost Alert"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Monitor/Create-Cost-Alert.ps1"
    arguments: "-BudgetName '$(BudgetName)' -BudgetAmount '$(BudgetAmount)' -BudgetResourceGroupScope '$(BudgetResourceGroupScope)' -BudgetManagementGroupScope '$(BudgetManagementGroupScope)' -BudgetTimeGrain '$(BudgetTimeGrain)' -BudgetStartDate '$(BudgetStartDate)' -BudgetEndDate '$(BudgetEndDate)' -AlertThresholdType '$(AlertThresholdType)' -AlertThresholdOperator '$(AlertThresholdOperator)' -AlertThreshold '$(AlertThreshold)' -AlertContactEmails '$(AlertContactEmails)' -AlertContactRoles '$(AlertContactRoles)' -AlertContactActionGroups '$(AlertContactActionGroups)' -Filters '$(Filters)' -FilterOnTagName '$(FilterOnTagName)' -FilterOnTagValue '$(FilterOnTagValue)'"
```

# Code

[Click here to download this script](../../../../src/Monitor/Create-Cost-Alert.ps1)

# Links

[Azure CLI - az account show](https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az_account_show)

[Azure CLI - az rest](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az_rest)
[Azure CLI - create/update cost alert](https://docs.microsoft.com/en-us/rest/api/consumption/budgets/create-or-update)
