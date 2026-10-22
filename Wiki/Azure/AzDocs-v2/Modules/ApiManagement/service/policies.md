# policies

Target Scope: resourceGroup

## Synopsis
Creating a policy resource in an existing Api Management Service.

## Description
Creating a policy resource in an existing Api Management Service.
<pre>
module policies 'br:contosoregistry.azurecr.io/service/policies.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'policies')
  params: {
    apiManagementServiceName: apiManagementServiceName
    name: policyName
    format: format
    value: value
  }
}
</pre><br>
<p>Creates a policy resource with the name policyFragmentName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the existing API Management service instance. |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The resource name |
| format | string | <input type="checkbox"> | `'rawxml'` or `'rawxml-link'` or `'xml'` or `'xml-link'` | <pre>'rawxml'</pre> | Format of the policyContent. |
| value | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Contents of the Policy as defined by the format. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| servicePolicyName | string | The name of the created service policy instance. |
| servicePolicyId | string | The resource id of the created service policy instance. |

## Links
- [Bicep Microsoft.ApiManagement policies](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/policies?pivots=deployment-language-bicep)
