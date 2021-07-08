[[_TOC_]]

# Description

Sometimes you need to register a so called "provider" before you can use a certain resource type in Azure. This script registers that provider for you.

# Parameters

| Parameter                 | Example Value        | Description                         |
| ------------------------- | -------------------- | ----------------------------------- |
| ResourceProviderNamespace | `Microsoft.Insights` | The namespace you want to register. |

# YAML

```yaml
        - task: AzureCLI@2
           displayName: 'Register Provider'
           condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
           inputs:
               azureSubscription: '${{ parameters.SubscriptionName }}'
               scriptType: pscore
               scriptPath: '$(Pipeline.Workspace)/AzDocs/Resource-Provider/Register-Provider.ps1'
               arguments: "-ResourceProviderNamespace '$(ResourceProviderNamespace)'"
```

# Code

[Click here to download this script](../../../../src/Resource-Provider/Register-Provider.ps1)

# Links

[Azure CLI - az provider register](https://docs.microsoft.com/en-us/cli/azure/provider?view=azure-cli-latest#az_provider_register)
