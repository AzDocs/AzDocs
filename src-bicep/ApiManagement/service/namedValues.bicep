/*
.SYNOPSIS
Creating named values in an existing Api Management Service.
.DESCRIPTION
Creating named values in an existing Api Management Service. A named value can be plain text (use namedValuesValue), secret (namedValuesValue + IsNamedValueSecret=true ) or a reference to a secret in a key vault (secretIdentifier).
<pre>
module namedvalue 'br:contosoregistry.azurecr.io/service/namedvalues.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 49), 'appInsightsKey')
  params: {
    apiManagementServiceName: apimPost.outputs.apiManagementServiceName
    namedValuesDisplayName: 'appInsightsInstrumentationKey'
    namedValuesName: 'appInsightsKey'
    namedValuesInKeyVaultIdentifier: appInsights.outputs.appInsightsInstrumentationKey
  }
}
</pre>
<p>Creates a named value called appInsightsKey.</p>
.LINKS
- [Bicep Microsoft.ApiManagement named values](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/namedvalues?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The name of the existing API Management service instance.')
param apiManagementServiceName string

@description('The resource name for this named value.')
@maxLength(80)
@minLength(1)
param namedValuesName string

@description('The display name of the NamedValue. It may contain only letters, digits, periods, dashes and underscores')
param namedValuesDisplayName string = namedValuesName

@description('''
The resource id of a user assigned managed identity when used. This identity can be used to access a secret in a keyvault.
If it is not provided, the system assigned identity will be used. This also requires API Management service to be configured with aka.ms/apimmsi.
''')
param UserAssignedIdentityId string = ''

@description('''
The tags to apply to this resource. Consists of one or more strings.
''')
param tags array = []

@description('''
Key vault secret identifier of the secret. 
Providing a versioned secret will prevent auto-refresh. If you enter a key vault secret identifier yourself, ensure that it doesn't have version information. 
Otherwise, the secret won't rotate automatically in API Management after an update in the key vault.
This also requires API Management service to be configured with aka.ms/apimmsi
''')
@secure()
param secretIdentifier string = ''

@description('Determines whether the value is a secret and should be encrypted or not. Default value is false.')
param IsNamedValueSecret bool = false

@description('Value of the NamedValue. Can contain policy expressions. When used it may not be empty or consist only of whitespace. This property will not be filled on GET operations! Use listSecrets POST request to get the value.')
param namedValuesValue string = ''

resource apimService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource namedValue 'Microsoft.ApiManagement/service/namedValues@2023-03-01-preview' = {
  parent: apimService
  name: namedValuesName
  properties: {
    displayName: replace((namedValuesDisplayName),' ', '')
    tags: tags
    secret: !empty(secretIdentifier)? true: IsNamedValueSecret
    value: (empty(namedValuesValue) && empty(secretIdentifier)) ? namedValuesName : empty(namedValuesValue) ? null : namedValuesValue
    keyVault: empty(secretIdentifier) ? null :{
      identityClientId: empty(UserAssignedIdentityId) ? null : UserAssignedIdentityId
      secretIdentifier: secretIdentifier
    }
  }
}


@description('The resource id of the named value.')
output namedValueResourceId string = namedValue.id
@description('The name of the named value.')
output namedValueResourceName string = namedValue.name
