# devcenters

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 

## Synopsis
Creating a Dev Center resource.

## Description
This module creates a managed devops pool with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of the Dev Center. |
| devcenterName | string | <input type="checkbox" checked> | Length between 3-26 | <pre></pre> | The name of the Dev Center to upsert. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| identity | [IdentityType](#IdentityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| devCenterId | string | The resource ID of the Dev Center. |

## Examples
<pre>
module devcenter 'br:contosoregistry.azurecr.io/devcenter/devcenters:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'devce')
  params: {
    devcenterName: mydevcenter
  }
}
</pre>
<p>Creates a dev center with the given specs</p>

## Links
- [Bicep Microsoft.DevCenter](https://learn.microsoft.com/en-us/azure/templates/microsoft.devcenter/devcenters?pivots=deployment-language-bicep)
