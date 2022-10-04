# virtualNetworkPeerings-remote

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| spokeVNetName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Spoke VNet. This is the VNet you are trying to attach to the central hub. |
| spokeVNetResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub. |
| spokeVNetSubscriptionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The ID of the subscription where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub. |
| spokeEnvironmentType | string | <input type="checkbox" checked> | Length between 3-4 | <pre></pre> | The environment type of the subscription where the Spoke VNet resides in. For example: `dev`, `acc`, `prd`. This is the VNet you are trying to attach to the central hub. |
| hubVNetName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Hub VNet. This is the VNet which acts as the central Hub in the Hub/spoke model. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

