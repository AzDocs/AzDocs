# projects

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 

## Synopsis
Creating a Dev Center project.

## Description
This module creates a Dev Center project in an existing Dev Center.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of the Dev Center project. |
| devCenterName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Dev Center. |
| devCenterProjectName | string | <input type="checkbox" checked> | Length between 3-* | <pre></pre> | The name of the Dev Center project. |
| devCenterProjectDescription | string | <input type="checkbox"> | None | <pre>'Dev Center project'</pre> | The description of the Dev Center project. |
| identity | [IdentityType](#IdentityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| maxDevBoxesPerUser | int? | <input type="checkbox" checked> | None | <pre></pre> | When provided, allows to restrict how many dev boxes each developer can create in a project. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| devCenterProject | string | The resource ID of the project created in the Dev Center. |

## Examples
<pre>
module devcenterproject 'br:contosoregistry.azurecr.io/devcenter/projects:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'devpr')
  params: {
    devcenterName: mydevcenter
    devCenterProjectName: mydevcenterproject
  }
}
</pre>
<p>Creates a dev center project with the given specs</p>

## Links
- [Bicep Microsoft.Devcenter Projects](https://learn.microsoft.com/en-us/azure/templates/microsoft.devcenter/projects?pivots=deployment-language-bicep)
