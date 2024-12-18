# identities

Target Scope: resourceGroup

## Synopsis
Register or modify an identity provider in Api Management Service.

## Description
Register a new or modify an identity provider (for exampl AAD) in Api Management Service.<br>
<pre><br>
module diagnostics 'br:contosoregistry.azurecr.io/service/identities.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 58), 'identities')<br>
  params: {<br>
    allowedTenants: allowedTenants<br>
    apiManagementServiceName: 'apim-irma-${environentType}'<br>
    authority: authority<br>
    authenticationType: authenticationType<br>
    clientId: clientId<br>
    clientLibrary: clientLibrary<br>
    clientSecret: clientSecret<br>
    name: name<br>
    passwordResetPolicyName: passwordResetPolicyName<br>
    profileEditingPolicyName: profileEditingPolicyName<br>
    signinPolicyName: signinPolicyName<br>
    signinTenant: signinTenant<br>
    signupPolicyName: signupPolicyName<br>
  }<br>
}<br>
</pre><br>
<p>Register a new or modify an identity provider (for exampl AAD) </p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| apiManagementServiceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Character limit: 1-50<br><br>Valid characters:<br>Alphanumerics and hyphens.<br><br>Start with letter and end with alphanumeric.<br><br>Resource name must be unique across Azure. |
| name | string | <input type="checkbox" checked> | `'aad'` or `'aadB2C'` or `'facebook'` or `'google'` or `'microsoft'` or `'twitter'` | <pre></pre> | The resource name of the Identity Provider. |
| allowedTenants | string[] | <input type="checkbox" checked> | None | <pre></pre> | List of Allowed Tenants when configuring Azure Active Directory login. |
| authority | string? | <input type="checkbox" checked> | None | <pre></pre> | OpenID Connect discovery endpoint hostname for AAD or AAD B2C. |
| clientId | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Client Id of the Application in the external Identity Provider. It is App ID for Facebook login, Client ID for Google login, App ID for Microsoft. |
| clientLibrary | string? | <input type="checkbox" checked> | `'ADAL'` or `'MSAL-2'` | <pre></pre> | The client library to be used in the developer portal. Only applies to AAD and AAD B2C Identity Provider. |
| clientSecret | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Client secret of the Application in external Identity Provider, used to authenticate login request. For example, it is App Secret for Facebook login, API Key for Google login, Public Key for Microsoft. |
| passwordResetPolicyName | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Password Reset Policy Name. Only applies to AAD B2C Identity Provider. |
| profileEditingPolicyName | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Profile Editing Policy Name. Only applies to AAD B2C Identity Provider. |
| signinPolicyName | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Signin Policy Name. Only applies to AAD B2C Identity Provider. |
| signinTenant | string | <input type="checkbox" checked> | None | <pre></pre> | The TenantId to use instead of Common when logging into Active Directory. |
| signupPolicyName | string? | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Signup Policy Name. Only applies to AAD B2C Identity Provider. |
| authenticationType | string | <input type="checkbox" checked> | `'aad'` or `'aadB2C'` or `'facebook'` or `'google'` or `'microsoft'` or `'twitter'` | <pre></pre> | dentity Provider Type identifier. |

## Links
- [Bicep Microsoft.ApiManagement diagnostics](https://learn.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/identityproviders?pivots=deployment-language-bicep)
