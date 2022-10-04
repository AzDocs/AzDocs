# servers

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server upsert. |
| azureActiveDirectoryAdminObjectId | string | <input type="checkbox"> | Length between 0-36 | <pre>''</pre> | If you want to enable an AAD administrator for this SQL Server, you need to pass the Azure AD Object ID of the principal in this parameter. |
| azureActiveDirectoryAdminUserName | string | <input type="checkbox" checked> | None | <pre></pre> | Login name of the server administrator. |
| azureActiveDirectoryOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | If this is enabled, SQL authentication gets disabled and you will only be able to login using Azure AD accounts. |
| azureActiveDirectoryAdminPrincipalType | string | <input type="checkbox"> | `'Application'` or  `'Group'` or  `'User'` | <pre>'User'</pre> | Principal Type of the Azure AD sever administrator. |
| sqlAuthenticationAdminUsername | string | <input type="checkbox"> | None | <pre>''</pre> | The username for the administrator using SQL Authentication. Once created it cannot be changed. |
| sqlAuthenticationAdminPassword | string | <input type="checkbox" checked> | None | <pre></pre> | The password for the administrator using SQL Authentication (required for server creation). |
| vulnerabilityScanEmails | array | <input type="checkbox"> | None | <pre>[]</pre> | Provide an array of e-mailaddresses (strings) where the vulnerability reports should be sent to. |
| vulnerabilityScanStorageAccountName | string | <input type="checkbox" checked> | Length between 3-24 | <pre></pre> | The resource name of the storage account to be used for the vulnerabilityscans. This storage account should be pre-existing. |
| subnetResourceIdsToWhitelist | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of strings containing resource id\'s of the subnets you want to whitelist on this SQL Server.<br><br>For example:<br>[<br>&nbsp;&nbsp;&nbsp;'/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'<br>&nbsp;&nbsp;&nbsp;'/subscriptions/$(SubscriptionId)/resourceGroups/$(ResourceGroupName)/providers/Microsoft.Network/virtualNetworks/$(VirtualNetworkName)/subnets/$(SubnetName)'<br>] |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | The identity running this SQL server. This is a managed identity. Defaults to a system assigned managed identity. For object formatting & options, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.sql/servers?pivots=deployment-language-bicep#resourceidentity. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| vulnerabilityScanStorageAccountName | string | Output the storage account resource name where the vulnerability scan reports are stored for this SQL Server. |
| sqlServerName | string | Output the name of the SQL Server. |
| sqlServerResourceId | string | Output the resource ID of the SQL Server. |
| sqlServerIdentityPrincipalId | string | Output the principal id for the identity of this SQL Server. |

