[[_TOC_]]

# Description

This snippet will create a SQL Admin AD user. This is needed to enable Managed Identities (SQL Auth is not allowed).

# Parameters

| Parameter  | Example Value              | Description                                                                                                                    |
| ---------- | -------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| AdUserName | `sql_myproject`            | The username to use for this user. Use only lowercase characters and dots (.). Recommendation: prefix the username with `sql_` |
| AdPassword | `ThisIsMyC00LP@ssw0rd123!` | The password for the ad user                                                                                                   |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create SQL Admin"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/SQL-Server/Create-SQL-Admin.ps1"
    arguments: "-AdUserName '$(AdUserName)' -AdPassword '$(AdPassword)'"
```

# Code

[Click here to download this script](../../../../src/SQL-Server/Create-SQL-Admin.ps1)

# Links

[Azure CLI - az ad user create](https://docs.microsoft.com/en-us/cli/azure/ad/user?view=azure-cli-latest#az_ad_user_create)
