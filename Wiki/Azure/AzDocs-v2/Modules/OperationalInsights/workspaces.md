# workspaces

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logAnalyticsWorkspaceName | string | <input type="checkbox" checked> | Length between 4-63 | <pre></pre> | Specifies the name of the Log Analytics workspace. |
| sku | string | <input type="checkbox"> | `'Free'` or `'Standalone'` or `'PerNode'` or `'PerGB2018'` | <pre>'PerNode'</pre> | Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB. |
| retentionInDays | int | <input type="checkbox"> | Value between -1-730 | <pre>60</pre> | Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| logAnalyticsWorkspaceResourceId | string | Outputs the Log Analytics Workspace Resource ID. |
| logAnalyticsWorkspaceResourceName | string | Outputs the Log Analytics Workspace Resource Name. |
| logAnalyticsWorkspaceCustomerId | string | Outputs the Log Analytics Workspace Customer ID. |
| logAnalyticsWorkspacePrimaryKey | string |  |

