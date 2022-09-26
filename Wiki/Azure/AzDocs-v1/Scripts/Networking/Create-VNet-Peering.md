[[_TOC_]]

# Description

This snippet will allow VNet peering between VNets.

You will have to run this script twice, since you will have to peer the VNets from both sides.
So for example:

- Run 1 : `my-vnet` to `my-vnet-2`
- Run 2: `my-vnet-2` to `my-vnet`

Make sure to switch to the subscription your originating VNet comes from (parameter `VnetName`) when peering across subscriptions.

# Parameters

Some parameters from [General Parameter](/Azure/AzDocs-v1/Scripts) list.

| Parameter                         | Required                        | Example Value                          | Description                                                           |
| --------------------------------- | ------------------------------- | -------------------------------------- | --------------------------------------------------------------------- |
| VnetName                          | <input type="checkbox" checked> | `my-vnet-$(Release.EnvironmentName)`   | The name of the VNet you want to peer from.                           |
| VnetResourceGroupName             | <input type="checkbox" checked> | `my-resourcegroup`                     | The resourcegroup your VNet resides in.                               |
| RemoteVnetResourceGroupName       | <input type="checkbox" checked> | `other-resourcegroup`                  | The remote VNet resourcegroup you want to peer to.                    |
| RemoteVnetName                    | <input type="checkbox" checked> | `my-vnet-2-$(Release.EnvironmentName)` | The name of the remote VNet you want to peer to.                      |
| RemoteVnetSubscriptionId          | <input type="checkbox" checked> | `subscription-id`                      | The id of the subscription where your remote VNet resides.            |
| AllowForwardedTrafficToRemoteVnet | <input type="checkbox">         | `true`/`false`                         | If you allow forwarding traffic to the remote VNet. Defaults to true. |
| AllowVnetAccessToRemoteVnet       | <input type="checkbox">         | `true`/`false`                         | If you allow VNet access to the remote VNet. Defaults to true.        |
| CurrentSubscriptionId             | <input type="checkbox" checked> | `subscription-id`                      | The current subscription id you are peering from.                     |

# YAML

Be aware that this YAML example contains all parameters that can be used with this script. You'll need to pick and choose the parameters that are needed for your desired action.

```yaml
- task: AzureCLI@2
  displayName: "Peer VNet to (Remote) VNet"
  condition: and(succeeded(), eq(variables['DeployInfra'], 'true'))
  inputs:
    azureSubscription: "${{ parameters.SubscriptionName }}"
    scriptType: pscore
    scriptPath: "$(Pipeline.Workspace)/AzDocs/Networking/Create-VNet-Peering.ps1"
    arguments: "-VnetName '$(VnetName)' -VnetResourceGroupName '$(VnetResourceGroupName)' -RemoteVnetResourceGroupName '$(RemoteVnetResourceGroupName)' -RemoteVnetName '$(RemoteVnetName)' -RemoteVnetSubscriptionId '$(RemoteVnetSubscriptionId)' -AllowForwardedTrafficToRemoteVnet $(AllowForwardedTrafficToRemoteVnet) -AllowVnetAccessToRemoteVnet $(AllowVnetAccessToRemoteVnet)"
```

# Code

[Click here to download this script](../../../../src/Networking/Create-VNet-Peering.ps1)

# Links

[Azure CLI - az-network-vnet-peering-create](https://docs.microsoft.com/en-us/cli/azure/network/vnet/peering?view=azure-cli-latest#az-network-vnet-peering-create)
