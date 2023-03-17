[[_TOC_]]

# Description

This snippet will update MySQL configuration by the given name and optional value. If the value is not set, it will be reset to it's default. There needs to be an existing MySQL Server, so make sure you used the `Create-MySQL-Server` script before running this.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                    | Required                        | Example Value                               | Description                                                                                                                 |
| ---------------------------- | ------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| MySqlServerResourceGroupName | <input type="checkbox" checked> | `myteam-testapi-$(Release.EnvironmentName)` | The name of the resourcegroup you want your MySql server to be created in                                                   |
| MySqlServerName              | <input type="checkbox" checked> | `somemysqlserver$(Release.EnvironmentName)` | The name for the MySQL Server resource. It's recommended to use just alphanumerical characters without hyphens etc.         |
| MySqlServerConfigName        | <input type="checkbox" checked> | `redirect_enabled`                          | The name of the MySQL server setting you want to update.                                                                    |
| MySqlServerConfigValue       | <input type="checkbox">         | `ON`                                        | The value of the MySQL server setting you want to update. When omitted, the default value for the setting will be restored. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Update MySQL Server configuration"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/MySQL/Set-MySQL-Server-Configuration-Set.ps1"
    arguments: "-MySqlServerResourceGroupName '$(MySqlServerResourceGroupName)' -MySqlServerName '$(MySqlServerName)' -MySqlServerConfigName '$(MySqlServerConfigName)' -MySqlServerConfigValue '$(MySqlServerConfigValue)'"
```

# Code

[Click here to download this script](../../../../../src/MySQL/Set-MySQL-Server-Configuration-Set.ps1)

# Links

[Azure CLI - az mysql server configuration set](https://learn.microsoft.com/en-us/cli/azure/mysql/server/configuration?view=azure-cli-latest#az-mysql-server-configuration-set)
