# capacities

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="isAllowed">isAllowed</a>  | <pre>'NotAllowed' &#124; 'Allowed'</pre> |  | Whether to allow or not allow | 
| <a id="locations">locations</a>  | <pre>'westeurope' &#124; 'australiaeast' &#124; 'eastus' &#124; 'uksouth'</pre> |  | Valid location of the capacity | 

## Synopsis
Creating Security Copilot SCU's (Security compute units).

## Description
Microsoft Security Copilot (Security Copilot) is a generative AI-powered security solution that helps increase the efficiency and capabilities of defenders to improve security outcomes at machine speed and scale.

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

## Examples
<pre>
module vm 'br:contosoregistry.azurecr.io/securitycopilot/capacities:latest' = {
  name: 'deployment-scu'
  scope: resourceGroup
  params: {
    capacityName: 'copilot-capacity-dev'
  }
}
</pre>
<p>Creates a SCU (single one) for security copilot in west europe only</p>
<pre>
module vm 'br:contosoregistry.azurecr.io/securitycopilot/capacities:latest' = {
  name: 'deployment-scus'
  scope: resourceGroup
  params: {
    capacityName: 'copilot-capacity-dev'
    numberOfUnits: 3
  }
}
</pre>
<p>Creates 3 SCU's for security copilot in west europe only</p>

## Links
- [Microsoft Security Copilot](https://learn.microsoft.com/en-us/copilot/security/)<br>
- [Provision with azure first](https://learn.microsoft.com/en-us/copilot/security/get-started-security-copilot#option-2-provision-capacity-in-azure)
