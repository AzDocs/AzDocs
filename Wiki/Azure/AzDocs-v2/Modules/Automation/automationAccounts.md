# automationAccounts

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the key vault should be created. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| automationAccountName | string | <input type="checkbox" checked> | Length between 6-50 | <pre></pre> | The name of the Automation Account to be upserted.<br>Min length: 6<br>Max length: 50 |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Sets the identity property for the automation account<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: userAssignedIdentities<br>}' |
| disableLocalAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Indicates whether requests using non-AAD authentication are blocked |
| publicNetworkAccess | bool | <input type="checkbox"> | None | <pre>false</pre> | Indicates whether traffic on the non-ARM endpoint (Webhook/Agent) is allowed from the public internet |
| encryption | object | <input type="checkbox"> | None | <pre>{<br>  identity: {}<br>  keySource: 'Microsoft.Automation'<br>}</pre> | Set the encryption properties for the automation account<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;identity: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;userAssignedIdentity: any()<br>&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;keySource: 'Microsoft.Keyvault'<br>&nbsp;&nbsp;&nbsp;keyVaultProperties: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyName: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyvaultUri: 'string'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;keyVersion: 'string'<br>&nbsp;&nbsp;&nbsp;}<br>} |
| sku | object | <input type="checkbox"> | None | <pre>{<br>  capacity: null<br>  family: null<br>  name: 'Basic'<br>}</pre> | Sets the SKU of the automation account<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;capacity: null<br>&nbsp;&nbsp;&nbsp;family: null<br>&nbsp;&nbsp;&nbsp;name: 'Free'<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |

