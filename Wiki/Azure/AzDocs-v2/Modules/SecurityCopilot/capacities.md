# capacities

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="isAllowed">isAllowed</a>  | <pre>'NotAllowed' &#124; 'Allowed'</pre> |  | Whether to allow or not allow | 
| <a id="locations">locations</a>  | <pre>'westeurope' &#124; 'australiaeast' &#124; 'eastus' &#124; 'uksouth'</pre> |  | Valid location of the capacity | 

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| capacityName | string | <input type="checkbox" checked> | Length between 3-63 | <pre></pre> | Name of the capacity |
| numberOfUnits | int | <input type="checkbox"> | Value between 1-100 | <pre>1</pre> | Number of units |
| crossGeoCompute | isAllowed | <input type="checkbox"> | None | <pre>'NotAllowed'</pre> | Whether to allow cross-geo compute |
| location | locations | <input type="checkbox"> | None | <pre>'westeurope'</pre> | Location of the capacity |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| capacityId | string | ID of the capacity |
