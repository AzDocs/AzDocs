# groups

Target Scope: resourceGroup

## Synopsis
Create or add an group in Api Management Service.

## Description
Create an internal group or add an existing external group in Api Management Service.<br>
<pre><br>
module diagnostics 'br:contosoregistry.azurecr.io/service/groups.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 58), 'groups')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    groupName: groupName<br>
    groupDescription: groupDescription<br>
    groupExternalId: groupExternalId<br>
    groupType: groupType<br>
  }<br>
}<br>
</pre><br>
<p>Create an internal group or add an existing external group in Api Management Service.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Character limit: 1-50<br><br>Valid characters:<br>Alphanumerics and hyphens.<br><br>Start with letter and end with alphanumeric.<br><br>Resource name must be unique across Azure. |
| groupDescription | string? | <input type="checkbox" checked> | None | <pre></pre> | Group description. |
| groupName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Group name. |
| groupExternalId | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Identifier of the external groups, this property contains the id of the group from the external identity provider, e.g. <br>for Azure Active Directory: <br><br>`aad://<tenant>.onmicrosoft.com/groups/<group object id>` <br><br>otherwise the value is null. |
| groupType | string | <input type="checkbox"> | `'custom'` or `'external'` or `'system'` | <pre>'custom'</pre> | Group type. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| groupId | string | The id of the group. |
| groupName | string | The name of the group. |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/groups?pivots=deployment-language-bicep)
