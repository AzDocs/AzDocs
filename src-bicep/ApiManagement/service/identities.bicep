/*
.SYNOPSIS
Register or modify an identity provider in Api Management Service.
.DESCRIPTION
Register a new or modify an identity provider (for exampl AAD) in Api Management Service.
<pre>
module diagnostics 'br:contosoregistry.azurecr.io/service/groups.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 58), 'groups')
  params: {
    allowedTenants: allowedTenants
    apiManagementServiceName: 'apim-irma-${environentType}'
    authority: authority
    authenticationType: authenticationType
    clientId: clientId
    clientLibrary: clientLibrary
    clientSecret: clientSecret
    name: name
    passwordResetPolicyName: passwordResetPolicyName
    profileEditingPolicyName: profileEditingPolicyName
    signinPolicyName: signinPolicyName
    signinTenant: signinTenant
    signupPolicyName: signupPolicyName
  }
}
</pre>
<p>Register a new or modify an identity provider (for exampl AAD) </p>
.LINKS
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/identityproviders?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('''
Character limit: 1-50

Valid characters:
Alphanumerics and hyphens.

Start with letter and end with alphanumeric.

Resource name must be unique across Azure.
''')
@minLength(1)
@maxLength(50)
param apiManagementServiceName string

@allowed([
  'aad'
  'aadB2C'
  'facebook'
  'google'
  'microsoft'
  'twitter'
])
@description('The resource name of the Identity Provider.')
param name string

@description('List of Allowed Tenants when configuring Azure Active Directory login.')
param allowedTenants string[]

@description('OpenID Connect discovery endpoint hostname for AAD or AAD B2C.')
param authority string?

@minLength(1)
@description('Client Id of the Application in the external Identity Provider. It is App ID for Facebook login, Client ID for Google login, App ID for Microsoft.')
param clientId string

@allowed([
  'ADAL'
  'MSAL'
])
@description('The client library to be used in the developer portal. Only applies to AAD and AAD B2C Identity Provider.')
param clientLibrary string?

@minLength(1)
@description('Client secret of the Application in external Identity Provider, used to authenticate login request. For example, it is App Secret for Facebook login, API Key for Google login, Public Key for Microsoft.')
@secure()
param clientSecret string

@minLength(1)
@description('Password Reset Policy Name. Only applies to AAD B2C Identity Provider.')
param passwordResetPolicyName string?

@minLength(1)
@description('Profile Editing Policy Name. Only applies to AAD B2C Identity Provider.')
param profileEditingPolicyName string?

@minLength(1)
@description('Signin Policy Name. Only applies to AAD B2C Identity Provider.')
param signinPolicyName string?

@description('The TenantId to use instead of Common when logging into Active Directory.')
param signinTenant string

@minLength(1)
@description('Signup Policy Name. Only applies to AAD B2C Identity Provider.')
param signupPolicyName string?

@allowed([
  'aad'
  'aadB2C'
  'facebook'
  'google'
  'microsoft'
  'twitter'
])
@description('dentity Provider Type identifier.')
param authenticationType string

resource apiManagementService 'Microsoft.ApiManagement/service@2023-03-01-preview' existing = {
  name: apiManagementServiceName
}

resource symbolicname 'Microsoft.ApiManagement/service/identityProviders@2023-03-01-preview' = {
  parent: apiManagementService
  name: name
  properties: {
    allowedTenants: allowedTenants
    authority: authority
    clientId: clientId
    clientLibrary: clientLibrary
    clientSecret: clientSecret
    passwordResetPolicyName: passwordResetPolicyName
    profileEditingPolicyName: profileEditingPolicyName
    signinPolicyName: signinPolicyName
    signinTenant: signinTenant
    signupPolicyName: signupPolicyName
    type: authenticationType
  }
}
