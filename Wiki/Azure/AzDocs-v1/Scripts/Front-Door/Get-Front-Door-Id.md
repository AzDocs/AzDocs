[[_TOC_]]

# Description

This snippet gets the front door id of the specified Front Door profile.

# Parameters

| Parameter                       | Required                        | Example Value                                                                                                                                   | Description                                                                                                                                       |
| ------------------------------- | ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| FrontDoorProfileName            | <input type="checkbox" checked> | `azurefrontdoorprofile`                                                                                                                         | The name of the Front Door profile                                                                                                                |
| FrontDoorResourceGroup          | <input type="checkbox" checked> | `rg-$(Release.EnvironmentName)`                                                                                                                 | The name of the resourcegroup the Front Door Profile resides in.                                                                                  |
| OutputPipelineVariableName                    | <input type="checkbox"> | `FrontDoorId`                                                                                          | The output pipeline variable name. Defaults to `FrontDoorId`.                                                                                                |

# YAML task

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Get Front Door Id"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Front-Door/Get-Front-Door-Id.ps1"
    arguments: >
        -FrontDoorProfileName '$(FrontDoorProfileName)'
        -FrontDoorResourceGroup '$(FrontDoorResourceGroup)'
        -OutputPipelineVariableName '$(OutputPipelineVariableName)'
```

# Code

[Click here to download this script](../../../../../src/Front-Door/Get-Front-Door-Id.ps1)

# Links

[Azure CLI - az afd profile create](https://docs.microsoft.com/nl-nl/cli/azure/afd/profile?view=azure-cli-latest#az-afd-profile-show)