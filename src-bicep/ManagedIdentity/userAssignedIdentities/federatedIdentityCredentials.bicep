/*
.SYNOPSIS
Creating a Federated Identity Credential for a User Assigned Managed Identity.
.DESCRIPTION
This Bicep file provisions a federated identity credential for an existing user-assigned managed identity.
.EXAMPLE
<pre>
module federatedIdentityCredentials 'br:contosoregistry.azurecr.io/managedidentity/federatedidentitycredentials:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'fedcred')
  params: {
    federatedIdentityCredentialsName: 'myFederatedIdentityCredential'
    userAssignedManagedIdentityName: 'myUserAssignedManagedIdentity'
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:tech/az4k-bicep-func-codedeploy:environment:dev'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}
</pre>
<p>Creates a federated identity with the name myFederatedIdentityCredential for a Github scenario</p>
.EXAMPLE
<pre>
module federatedIdentityCredentials 'br:contosoregistry.azurecr.io/managedidentity/federatedidentitycredentials:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 56), 'fedcred')
  params: {
    federatedIdentityCredentialsName: 'myFederatedIdentityCredential'
    userAssignedManagedIdentityName: 'myUserAssignedManagedIdentity'
    issuer: 'https://vstoken.dev.azure.com/713fdea1-6ffb-4a0f-af30-8a6dd8b003d7'
    subject: 'sc://devopsorgname/azure4/managed-devopspool2-dev'
    audiences: [
      'api://AzureADTokenExchange'
    ]
  }
}
</pre>
<p>Creates a federated identity with the name myFederatedIdentityCredential for a Azure DevOps scenario.</p>
.LINKS
- [Bicep Microsoft.ManagedIdentity/userAssignedIdentities federatedIdentityCredentials](https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/2024-11-30/userassignedidentities/federatedidentitycredentials?pivots=deployment-language-bicep)
- [Configure a user-assigned managed identity to trust an external identity provider](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp)
- [Use the Azure Login action from GitHub Actions workflows with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)
- [Manually set an Azure Resource Manager workload identity service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/configure-workload-identity?view=azure-devops&tabs=managed-identity)
*/

// ===================================== Parameters =====================================

@description('The name of the federated identity credential to create.')
@minLength(3)
@maxLength(120)
param federatedIdentityCredentialsName string

@description('The name of the already existing user-assigned managed identity for this federated identity credential.')
param userAssignedManagedIdentityName string

@description('''
The issuer URL for the federated identity credential. The URL of the issuer to be trusted.
Example:
'https://token.actions.githubusercontent.com'
''')
param issuer string

@description('''
The subject claim for the federated identity credential. 
When used for Connecting a Github account, it is the concatenation of the GitHub organisation, the repository and the entity (tag, environment, PR, branch).
Example:
'repo:<ORG_NAME>/<REPO_NAME>:environment:<EnvironmentTypeName>'
''')
param subject string

@description('The audiences for the federated identity credential. The list of audiences that can appear in the issued token.')
param audiences array = [
  'api://AzureADTokenExchange'
]

// ===================================== Resources =====================================

@description('The existing user-assigned managed identity.')
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = {
  name: userAssignedManagedIdentityName
}

@description('The federated identity credential for the user-assigned managed identity.')
resource federatedIdentityCredentials 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = {
  parent: userAssignedManagedIdentity
  name: federatedIdentityCredentialsName
  properties: {
    issuer: issuer
    subject: subject
    audiences: audiences
  }
}

// ===================================== Outputs =====================================

@description('The name of the created federated identity credential.')
output federatedIdentityCredentialsName string = federatedIdentityCredentials.name

@description('The resource ID of the created federated identity credential.')
output federatedIdentityCredentialsId string = federatedIdentityCredentials.id
