metadata name = 'Common Authorization Resource Types'
metadata description = 'Shared user-defined types for Azure authorization resources across all modules.'

/*
.SYNOPSIS
Common authorization resource types
.DESCRIPTION
This module defines shared user-defined types for authorization resources that can be used across all Azure modules.
These types provide type safety and documentation for authorization parameters.
.LINKS
- [Azure Authorization role assignment](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

// ================================================= User-Defined Types =================================================

@export()
@description('Role assignment resource options')
type roleAssignment = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: PrincipalType?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}

@export()
@description('The type of principal that can be assigned a role.')
type PrincipalType =
  | 'User'
  | 'Group'
  | 'ServicePrincipal'
  | 'Unknown'
  | 'DirectoryRoleTemplate'
  | 'ForeignGroup'
  | 'Application'
  | 'MSI'
  | 'DirectoryObjectOrGroup'
  | 'Everyone'
