# aliases

Target Scope: managementGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| subscriptionName | string | <input type="checkbox" checked> | Length between 1-64 | <pre></pre> | The subscription name. Preferably without spaces. |
| billingScopeResourceId | string | <input type="checkbox" checked> | None | <pre></pre> | Provide the full resource ID of billing scope to use for subscription creation. |
| subscriptionWorkloadType | string | <input type="checkbox" checked> | `'Production'` or  `'DevTest'` | <pre></pre> | The workload type of this subscription. |
| subscriptionOwnerId | string | <input type="checkbox"> | Length between 0-36 | <pre>''</pre> | Azure AD Object ID of the principal that should be made owner of this created subscription. |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| subscriptionId | string | Output the subscription id to be used in the further part of the pipeline |

