[[_TOC_]]

# Description

Create a Dashboard from a Tempalate. The TagValueDictionary parameter should contain a list of regex names with a value to replace with. See also templates\Dashboards\Template-Cost-Dashboard.json for an example of a cost dashboard.

# Parameters

| Parameter                  | Required                        | Example Value                                                                 | Description                                                |
| -------------------------- | ------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------- |
| Location                   | <input type="checkbox" >        | `westeurope`                                                                  | The location in Azure the resource group should be created |
| DashboardResourceGroupName | <input type="checkbox" checked> | `dashboard-$(Release.EnvironmentName)`                                        | The name of the dashboard's ResourceGroup                  |
| DashboardName              | <input type="checkbox" checked> | `myteam-dashboard-$(Release.EnvironmentName)`                                 | The name of the dashboard to create                        |
| TemplateFilePath           | <input type="checkbox" checked> | `Template.json`                                                               | Path of the template file                                  |
| TagValueDictionary         | <input type="checkbox" checked> | `([ordered]@{'###SubscriptionId###'='f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43'})` | Dictionary with tags to use and actual strings to replace  |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create Dashboard from template"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Dashboards/Set-DashboardFromTemplate.ps1"
    arguments: "-ResourceGroupLocation '$(ResourceGroupLocation)' -DashboardResourceGroupName 'MyResourceGroup' -DashboardName 'MyFirstDashboard' -TemplateFilePath 'Template.json' -TagValueDictionary ([ordered]@{'###SubscriptionId###'='f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43'})"
```

# Code

[Click here to download this script](../../../../../src/Dashboards/Set-DashboardFromTemplate.ps1)

# Links

[Azure CLI - az portal dashboard create](https://docs.microsoft.com/en-us/cli/azure/portal/dashboard?view=azure-cli-latest#az_portal_dashboard_create)