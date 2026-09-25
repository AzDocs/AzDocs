# authorizationTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="roleAssignment">roleAssignment</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')<br>&nbsp;&nbsp;&nbsp;roleDefinitionIdOrName: string<br><br>&nbsp;&nbsp;&nbsp;@description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')<br>&nbsp;&nbsp;&nbsp;principalId: string<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. The principal type of the assigned principal ID.')<br>&nbsp;&nbsp;&nbsp;principalType: PrincipalType?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. The description of the role assignment.')<br>&nbsp;&nbsp;&nbsp;description: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')<br>&nbsp;&nbsp;&nbsp;condition: string?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. Version of the condition.')<br>&nbsp;&nbsp;&nbsp;conditionVersion: '2.0'?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. The Resource Id of the delegated managed identity resource.')<br>&nbsp;&nbsp;&nbsp;delegatedManagedIdentityResourceId: string?<br>}<br></pre> |  | Role assignment resource options | 
| <a id="PrincipalType">PrincipalType</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; 'User'<br>&nbsp;&nbsp;&nbsp;&#124; 'Group'<br>&nbsp;&nbsp;&nbsp;&#124; 'ServicePrincipal'<br>&nbsp;&nbsp;&nbsp;&#124; 'Unknown'<br>&nbsp;&nbsp;&nbsp;&#124; 'DirectoryRoleTemplate'<br>&nbsp;&nbsp;&nbsp;&#124; 'ForeignGroup'<br>&nbsp;&nbsp;&nbsp;&#124; 'Application'<br>&nbsp;&nbsp;&nbsp;&#124; 'MSI'<br>&nbsp;&nbsp;&nbsp;&#124; 'DirectoryObjectOrGroup'<br>&nbsp;&nbsp;&nbsp;&#124; 'Everyone'</pre> |  | The type of principal that can be assigned a role. | 

## Synopsis
Common authorization resource types

## Description
This module defines shared user-defined types for authorization resources that can be used across all Azure modules.<br>
These types provide type safety and documentation for authorization parameters.

## Links
- [Azure Authorization role assignment](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
