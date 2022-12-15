[[_TOC_]]

# Description

This snippet will give you the ObjectID for a Service User. This objectid is needed in the [Grant AppService dataread&write&ddladmin rights on SQL Server](/Azure/AzDocs-v1/Scripts/SQL-Server/Grant-AppService-dataread&write&ddladmin-rights-on-SQL-Server) step for example.

NOTE: THIS IS CANNOT BE A SERVICE PRINCIPAL USER but should be a AD User.

# Parameters

| Parameter                  | Required                        | Example Value              | Description                                                                                                                                |
| -------------------------- | ------------------------------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| ServiceUserEmail           | <input type="checkbox" checked  | `my_user@domain.com`       | The e-mailaddress for the service user                                                                                                     |
| ServiceUserPassword        | <input type="checkbox" checked> | `ThisIsMyC00LP@ssw0rd123!` | The password for the service user                                                                                                          |
| OutputPipelineVariableName | <input type="checkbox">         | `ServiceUserObjectId`      | The name of the pipeline variable. This defaults to `ServiceUserObjectId` and can be used inside the pipeline as `$(ServiceUserObjectId)`. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Get ObjectID for ServiceUser"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Users-and-Accounts/Get-ObjectID-for-ServiceUser.ps1"
    arguments: "-ServiceUserEmail '$(ServiceUserEmail)' -ServiceUserPassword '$(ServiceUserPassword)' -OutputPipelineVariableName '$(OutputPipelineVariableName)'"
```

# Code

[Click here to download this script](../../../../../src/Users-and-Accounts/Get-ObjectID-for-ServiceUser.ps1)

# Links

[Azure CLI - az-login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

[Azure CLI - az-ad-user-show](https://docs.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az-ad-user-show)
