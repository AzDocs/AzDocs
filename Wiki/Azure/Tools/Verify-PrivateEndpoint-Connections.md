[[_TOC_]]

# Description

This snippet will verify private endpoint connections and will show which of the ones are orphaned.
Next to that, it is also possible to delete these 'orphaned' private endpoint connections by setting the `EnableDeletion` parameter.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter        | Required                        | Example Value      | Description                                                       |
| ---------------- | ------------------------------- | ------------------ | ----------------------------------------------------------------- |
| SubscriptionName | <input type="checkbox" checked> | `SubscriptionName` | Name of the Subscription.                                         |
| EnableDeletion   | <input type="checkbox">         | `$true`/ `$false`  | Enabling the deletion of the private endpoints that are orphaned. |

# YAML

Make sure to include the `Tools` folder in your artifact as well.
Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Verify Private Endpoint Connections"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Tools/Verify-PrivateEndpoint-Connections.ps1"
    arguments: "-SubscriptionName '$(SubscriptionName)' -EnableDeletion $(EnableDeletion)"
```

# Code

[Click here to download this script](../../../../Tools/Verify-PrivateEndpoint-Connections.ps1)

# Links

[Azure CLI - az network private endpoint](https://docs.microsoft.com/en-us/cli/azure/network/private-endpoint?view=azure-cli-latest#commands)
