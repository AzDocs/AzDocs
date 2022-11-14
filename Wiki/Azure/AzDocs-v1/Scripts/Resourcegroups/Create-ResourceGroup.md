[[_TOC_]]

# Description

This snippet will create a Resource Group if it does not exist. It also adds the mandatory tags to the resource group

# Parameters

| Parameter             | Required                        | Example Value                                               | Description                                                |
| --------------------- | ------------------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- |
| ResourceGroupLocation | <input type="checkbox" checked> | `westeurope`                                                | The location in Azure the resource group should be created |
| ResourceGroupName     | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)`                 | The name for the resource group                            |
| ResourceTags          | <input type="checkbox">         | `@('tagnamefirst=tagvalue1'; 'tagnamesecond=tagnamesecond'` | Collection of tags to set on the resourcegroup             |
# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create ResourceGroup"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Resourcegroup/Create-ResourceGroup.ps1"
    arguments: "-ResourceGroupLocation '$(ResourceGroupLocation)' -ResourceGroupName '$(ResourceGroupName)' -ResourceTags $(ResourceTags)"
```

# Code

[Click here to download this script](../../../../../src/Resourcegroup/Create-ResourceGroup.ps1)

# Links

[Azure CLI - az group create](https://docs.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest#az-group-create)
