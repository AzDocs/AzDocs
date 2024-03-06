# resourceGroups

Target Scope: subscription

## Synopsis
Creating a Resource Group.

## Description
Creating a Resource Group.

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

## Examples
<p>Creates a Resource group with the name  MyFirstRg in subscriptionId a56350f0-347b-4393-963e-e3e090286fd6</p>
<pre>
param location string = 'westeurope'
var subscriptionId = 'a56350f0-347b-4393-963e-e3e090286fd6'
module rg '../../AzDocs/src-bicep/Resources/resourceGroups.bicep' = {
  name: 'Creating_RG_MyFirstVM'
  scope: az.subscription(subscriptionId)
  params: {
    resourceGroupName: 'MyFirstRg'
    location: location
  }
}
</pre>

## Links
- [Bicep Microsoft.Resources resourceGroups](https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups?pivots=deployment-language-bicep)
