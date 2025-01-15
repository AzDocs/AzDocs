# virtualNetworkPeerings

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| spokeVNetName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Spoke VNet. This is the VNet you are trying to attach to the central hub. |
| spokeVNetResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub. |
| spokeVNetSubscriptionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The ID of the subscription where the Spoke VNet resides in. This is the VNet you are trying to attach to the central hub. |
| spokeEnvironmentType | string | <input type="checkbox" checked> | Length between 3-4 | <pre></pre> | The environment type of the subscription where the Spoke VNet resides in. For example: `dev`, `acc`, `prd`. This is the VNet you are trying to attach to the central hub. |
| hubVNetSubscriptionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The ID of the subscription where the Hub VNet resides in. This is the VNet which acts as the central Hub in the Hub/spoke model. |
| hubVNetResourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup where the Hub VNet resides in. This is the VNet which acts as the central Hub in the Hub/spoke model. |
| hubVNetName | string | <input type="checkbox" checked> | Length between 2-64 | <pre></pre> | The name of the Hub VNet. This is the VNet which acts as the central Hub in the Hub/spoke model. |
| hubSpokeVNetNameInfix | string | <input type="checkbox"> | Length between 0-2 | <pre>''</pre> | An optional infix to add to the VNet name in the name of the peering on the remote site: vnet-purpose-<infix>-env |
