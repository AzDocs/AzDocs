# userAssignedIdentities

Target Scope: resourceGroup

## Synopsis
Creating a User Assigned Managed Identity.

## Description
This Bicep file provisions a userassigned managed identity with the specified name, location, and tags.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of this logic app to reside in. This defaults to the resourcegroup location. |
| userAssignedManagedIdentityName | string | <input type="checkbox" checked> | Length between 3-128 | <pre></pre> | The name to assign to this user assigned managed identity. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| userManagedIdentityId | string | The User Assigned Managed Identities Resource ID. |
| userManagedIdentityPrincipalId | string | The User Assigned Managed Identities Principal ID. |
| userManagedIdentityClientId | string | The User Assigned Managed Identities Client ID. |
| userManagedIdentityName | string | The User Assigned Managed Identities Resource name. |
| userManagedIdentityObjectId | string | The User Assigned Managed Identities Object (principal) ID. |

## Examples
<pre>
module userAssignedIdentity 'br:contosoregistry.azurecr.io/managedidentity/userassignedidentities:latest' = {
  name: 'userAssignedIdentityDeployment'
  params: {
    userAssignedManagedIdentityName: 'myManagedIdentity'
    tags: {
      Environment: 'Development'
      Project: 'ManagedIdentity'
    }
  }
}
</pre>
<p>Creates a user assigned managed identity with the name myManagedIdentity</p>

## Links
- [Bicep Microsoft.ManagedIdentity userAssignedIdentities](https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/2024-11-30/userassignedidentities?pivots=deployment-language-bicep)
