[[_TOC_]]

# Description

This snippet will apply an existing NAT gateway to a subnet.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                  | Example Value                              | Description                                                                               |
| -------------------------- | ------------------------------------------ | ----------------------------------------------------------------------------------------- |
| VnetName                   | `myvnet-$(EnvironmentName)`                | The name of the VNet where the subnet (which you want to apply the NAT gateway to) lives. |
| VnetResourceGroupName      | `mysharedresourcegroup-$(EnvironmentName)` | The resource group where the VNet resides in.                                             |
| SubnetName                 | `app-subnet-1`                             | The name of the subnet to apply the NAT Gateway to                                        |
| NatGatewayName             | `mynatgateway-$(EnvironmentName)`          | The name of the existing NAT Gateway.                                                     |
| NatGatewayResouceGroupName | `mysharedresourcegroup-$(EnvironmentName)` | The resource group where the NAT Gateway resides in.                                      |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Apply NAT Gateway to Subnet"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/NAT-Gateway/Apply-NAT-Gateway-To-Subnet.ps1"
    arguments: "-VnetName '$(VnetName)' -VnetResourceGroupName '$(VnetResourceGroupName)' -SubnetName '$(SubnetName)' -NatGatewayName '$(NatGatewayName)' -NatGatewayResouceGroupName '$(NatGatewayResouceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Networking/NAT-Gateway/Apply-NAT-Gateway-To-Subnet.ps1)

# Links

[Azure CLI - az network vnet subnet show](https://docs.microsoft.com/nl-nl/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_show)

[Azure CLI - az network nat gateway show](https://docs.microsoft.com/nl-nl/cli/azure/network/nat/gateway?view=azure-cli-latest#az_network_nat_gateway_show)

[Azure CLI - az network vnet subnet update](https://docs.microsoft.com/nl-nl/cli/azure/network/vnet/subnet?view=azure-cli-latest#az_network_vnet_subnet_update)
