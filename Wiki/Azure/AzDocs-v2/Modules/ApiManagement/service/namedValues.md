# namedValues

Target Scope: resourceGroup

## Synopsis
Creating named values in an existing Api Management Service.

## Description
Creating named values in an existing Api Management Service. A named value can be plain text (use namedValuesValue), secret (namedValuesValue + IsNamedValueSecret=true ) or a reference to a secret in a key vault (secretIdentifier).<br>
<pre><br>
module namedvalue 'br:contosoregistry.azurecr.io/service/namedvalues.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 49), 'appInsightsKey')<br>
  params: {<br>
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName<br>
    namedValuesDisplayName: 'appInsightsInstrumentationKey'<br>
    namedValuesName: 'appInsightsKey'<br>
    namedValuesInKeyVaultIdentifier: appInsights.outputs.appInsightsInstrumentationKey<br>
  }<br>
}<br>
</pre><br>
<p>Creates a named value called appInsightsKey.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing API Management service instance. |
| namedValuesName | string | <input type="checkbox" checked> | Length between 1-80 | <pre></pre> | The resource name for this named value. |
| namedValuesDisplayName | string | <input type="checkbox"> | None | <pre>namedValuesName</pre> | The display name of the NamedValue. It may contain only letters, digits, periods, dashes and underscores |
| userAssignedIdentityId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of a user assigned managed identity when used. This identity can be used to access a secret in a keyvault.<br>If it is not provided, the system assigned identity will be used. This also requires API Management service to be configured with aka.ms/apimmsi. |
| tags | array | <input type="checkbox"> | None | <pre>[]</pre> | The tags to apply to this resource. Consists of one or more strings. |
| secretIdentifier | string | <input type="checkbox"> | None | <pre>''</pre> | Key vault secret identifier of the secret. <br>Providing a versioned secret will prevent auto-refresh. If you enter a key vault secret identifier yourself, ensure that it doesn't have version information. <br>Otherwise, the secret won't rotate automatically in API Management after an update in the key vault.<br>This also requires API Management service to be configured with aka.ms/apimmsi |
| isNamedValueSecret | bool | <input type="checkbox"> | None | <pre>false</pre> | Determines whether the value is a secret and should be encrypted or not. Default value is false. |
| namedValuesValue | string | <input type="checkbox"> | None | <pre>''</pre> | Value of the NamedValue. Can contain policy expressions. When used it may not be empty or consist only of whitespace. This property will not be filled on GET operations! Use listSecrets POST request to get the value. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| namedValueResourceId | string | The resource id of the named value. |
| namedValueResourceName | string | The name of the named value. |

## Links
- [Bicep Microsoft.ApiManagement named values](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/namedvalues?pivots=deployment-language-bicep)
