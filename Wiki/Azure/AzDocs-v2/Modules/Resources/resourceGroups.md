# resourceGroups

Target Scope: subscription

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>'westeurope'</pre> | Specifies the Azure location where the resource should be created. |
| resourceGroupName | string | <input type="checkbox" checked> | Length between 1-90 | <pre></pre> | The name of the resourcegroup to upsert. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resourcegroup. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| resourceGroupName | string | Output the name of the resourcegroup. |

