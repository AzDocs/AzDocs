[[_TOC_]]

# Description

This code will create a CDN Profile

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter        | Required                        | Example Value                                  | Description                                                                                                                                              |
| ---------------- | ------------------------------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CdnProfileName   | <input type="checkbox" checked> | `shared-cdn`                                   | The name of the cdn profile.                                                                                                                             |
| CdnResourceGroup | <input type="checkbox" checked> | `my-resource-group-$(Release.EnvironmentName)` | The name of the resource group                                                                                                                           |
| Sku              | <input type="checkbox">         | `Standard_Akamai`                              | Sku options. Options are currently : `Custom_Version`, `Premium_Verizon` `Standard_Akamai`, `Standard_ChinaCdn`,`Standard_Microsoft`, `Standard_Verizon` |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create CDN Profile name"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/CDN/Create-CDN-Profile.ps1"
    arguments: "-CdnProfileName '$(CdnProfileName)' -CdnResourceGroup '$(CdnResourceGroup)' -Sku '$(Sku)'"
```

# Code

[Click here to download this script](../../../../../src/CDN/CDN/Create-CDN-Profile.ps1)

# Links

- [Azure Ccli - Configure CDN profile](https://docs.microsoft.com/en-us/cli/azure/cdn/profile?view=azure-cli-latest)
