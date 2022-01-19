[[_TOC_]]

# Description

Create a template from a dashboard. The TagValueDictionary parameter should contain a list of regex names with a value to replace with. See also templates\Dashboards\Template-Cost-Dashboard.json for an example of a cost dashboard.

# Parameters

| Parameter                  | Required                        | Example Value                                                                 | Description                                                |
| -------------------------- | ------------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------- |
| DashboardResourceGroupName| <input type="checkbox" checked> | `dashboard-$(Release.EnvironmentName)`                                        | The name of the ResourceGroup                              |
| DashboardName              | <input type="checkbox" checked> | `myteam-dashboard-$(Release.EnvironmentName)`                                 | The name of the dashboard to fetch                         |
| TemplateFilePath           | <input type="checkbox" checked> | `Template.json`                                                               | Path of the template file                                  |
| TagValueDictionary         | <input type="checkbox" checked> | `([ordered]@{'###SubscriptionId###'='f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43'})` | Dictionary with tags to use and actual strings to replace  |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create template from Dashboard"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Dashboards/Get-DashboardTemplate.ps1"
    arguments: "-DashboardResourceGroupName 'MyResourceGroup' -DashboardName 'MyFirstDashboard' -TemplateFilePath 'Template.json' -TagValueDictionary ([ordered]@{'###SubscriptionId###'='f5b5eb5d-f95a-49ed-bde3-c5ad5f6c4c43'})"
```

# Code

[Click here to download this script](../../../../src/Dashboards/Get-DashboardTemplate.ps1)

# Links

[Azure CLI - az portal dashboard show](https://docs.microsoft.com/en-us/cli/azure/portal/dashboard?view=azure-cli-latest#az_portal_dashboard_show)