# policyFragments

Target Scope: resourceGroup

## Synopsis
Creating a policy fragement to re-use in a policy definition in an existing Api Management Service.

## Description
Creating a policy fragement to re-use in a policy definition in an existing Api Management Service.<br>
<pre><br>
module policyFragment 'br:contosoregistry.azurecr.io/service/policyFragments.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 57), 'policyFragment')<br>
  params: {<br>
    apiManagementServiceName: apiManagementServiceName<br>
    name: policyFragmentName<br>
    fragmentDescription: description<br>
    fragmentValue: value<br>
  }<br>
}<br>
</pre><br>
<p>Creates a policy fragment with the name policyFragmentName.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | The name of the existing API Management service instance. |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The resource name |
| format | string | <input type="checkbox"> | `'rawxml'` or `'xml'` | <pre>'rawxml'</pre> | Format of the policy fragment content. |
| fragmentDescription | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The policy fragment description |
| fragmentValue | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Contents of the policy fragment. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| policyFragmentName | string | The name of the created policy fragment. |
| policyFragmentId | string | The resource id of the created policy fragment. |

## Links
- [Bicep Microsoft.ApiManagement policy fragments](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/policyfragments?pivots=deployment-language-bicep)
