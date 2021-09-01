[[_TOC_]]

# Description

With this snippet you can update your VNET with one or multiple custom DNS Servers.

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter  | Required                        | Example Value                           | Description                                                                                                     |
| ---------- | ------------------------------- | --------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| DNSServers | <input type="checkbox" checked> | `mykeyvault-$(Release.EnvironmentName)` | The ip address of the custom dns server. For multiple DNS servers you can add a space-separated list with ip's. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Custom DNS Server to VNET"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/Add-Custom-DNS-Server-To-VNET.ps1"
    arguments: "-VnetResourceGroupName '$(VnetResourceGroupName)' -VnetName '$(VnetName)' -DNSServers '$(DNSServers)'"
```

# Code

[Click here to download this script](../../../../src/Networking/Add-Custom-DNS-Server-To-VNET.ps1)

# Links

[Azure CLI - az network vnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_update)
