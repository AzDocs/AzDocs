[[_TOC_]]

# Description

This snippet will create a DDoS-protection resource and apply it to your VNet.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Add Custom DNS Server to VNET"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/Add-DDoS-Protection-Vnet.ps1"
    arguments: "-VnetResourceGroupName '$(VnetResourceGroupName)' -VnetName '$(VnetName)'"
```

# Code

[Click here to download this script](../../../../src/Networking/Add-DDoS-Protection-To-Vnet.ps1)

# Links

[Azure CLI - az network ddos-protection create](https://docs.microsoft.com/en-us/cli/azure/network/ddos-protection?view=azure-cli-latest#az_network_ddos_protection_create)

[Azure CLI - az network vnet update](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az_network_vnet_update)
