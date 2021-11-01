[[_TOC_]]

# Description

This snippet will create a NAT gateway for you

# Parameters

Some parameters from [General Parameter](/Azure/Azure-CLI-Snippets) list.

| Parameter                  | Example Value                              | Description                                              |
| -------------------------- | ------------------------------------------ | -------------------------------------------------------- |
| NatGatewayName             | `mynatgateway-$(EnvironmentName)`          | The name of the NAT Gateway.                             |
| NatGatewayResouceGroupName | `mysharedresourcegroup-$(EnvironmentName)` | The resource group where the NAT Gateway will reside in. |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Create NAT Gateway"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/NAT-Gateway/Create-NAT-Gateway.ps1"
    arguments: "-NatGatewayName '$(NatGatewayName)' -NatGatewayResouceGroupName '$(NatGatewayResouceGroupName)'"
```

# Code

[Click here to download this script](../../../../src/Networking/NAT-Gateway/Create-NAT-Gateway.ps1)

# Links

[Azure CLI - az network public-ip create](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_create)

[Azure CLI - az network public-ip show](https://docs.microsoft.com/en-us/cli/azure/network/public-ip?view=azure-cli-latest#az_network_public_ip_show)

[Azure CLI - az network nat gateway show](https://docs.microsoft.com/nl-nl/cli/azure/network/nat/gateway?view=azure-cli-latest#az_network_nat_gateway_show)

[Azure CLI - az network nat gateway create](https://docs.microsoft.com/nl-nl/cli/azure/network/nat/gateway?view=azure-cli-latest#az_network_nat_gateway_create)
