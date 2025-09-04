# authorizationTypes

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="roleAssignment">roleAssignment</a>  | <pre>{</pre> |  | Role assignment resource options | 
| <a id="PrincipalType">PrincipalType</a>  | <pre></pre> |  | The type of principal that can be assigned a role. | 

## Synopsis
Common authorization resource types

## Description
This module defines shared user-defined types for authorization resources that can be used across all Azure modules.<br>
These types provide type safety and documentation for authorization parameters.

## Links
- [Azure Authorization role assignment](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
