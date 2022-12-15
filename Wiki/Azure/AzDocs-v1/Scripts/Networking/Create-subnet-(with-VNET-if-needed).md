[[_TOC_]]

# Description

This snippet will create a VNET if it does not exist with a subnet if it doesnt exist. It also adds the mandatory tags to the VNET

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter             | Required                        | Example Value                        | Description                                                                                                              |
| --------------------- | ------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| VnetName              | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)` | The name of the VNET to use for your resource.                                                                           |
| VnetResourceGroupName | <input type="checkbox" checked> | `sharedservices-rg`                  | The ResourceGroup where your VNET resides in. If you are unsure use `sharedservices-rg`                                  |
| VnetCidr              | <input type="checkbox" checked> | `10.0.0.0/16`                        | The VNET address space to create. This uses the CIDR notation.                                                           |
| SubnetName            | <input type="checkbox" checked> | `app-subnet-3`                       | The name to use for the subnet to create.                                                                                |
| Subnet                | <input type="checkbox" checked> | `10.0.0.0/24`                        | The subnet identifier for the subnet to create. This uses the CIDR notation.                                             |
| DNSServers            | <input type="checkbox">         | `168.63.129.16`                      | Space separated list of DNS servers. This defauts to `168.63.129.16` (the default private endpoint DNS server for Azure) |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create subnet with VNET if needed"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/Create-subnet-with-VNET-if-needed.ps1"
    arguments: "-VnetResourceGroupName '$(VnetResourceGroupName)' -VnetName '$(VnetName)' -VnetCidr '$(VnetCidr)' -SubnetName '$(SubnetName)' -Subnet '$(Subnet)' -DNSServers '$(DNSServers)' -ResourceTags $(ResourceTags)"
```

# Code

[Click here to download this script](../../../../../src/Networking/Create-subnet-with-VNET-if-needed.ps1)

# Links

[Azure CLI - az-network-vnet-create](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-create)

[Azure CLI - az-network-vnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet?view=azure-cli-latest#az-network-vnet-show)

[Azure CLI - az-network-vnet-subnet-create](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-create)

[Azure CLI - az-network-vnet-subnet-show](https://docs.microsoft.com/en-us/cli/azure/network/vnet/subnet?view=azure-cli-latest#az-network-vnet-subnet-show)
