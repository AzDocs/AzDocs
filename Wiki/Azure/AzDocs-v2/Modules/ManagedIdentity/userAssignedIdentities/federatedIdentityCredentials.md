# federatedIdentityCredentials

Target Scope: resourceGroup

## Synopsis
Creating a Federated Identity Credential for a User Assigned Managed Identity.

## Description
This Bicep file provisions a federated identity credential for an existing user-assigned managed identity.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| federatedIdentityCredentialsName | string | <input type="checkbox" checked> | Length between 3-120 | <pre></pre> | The name of the federated identity credential to create. |
| userAssignedManagedIdentityName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the already existing user-assigned managed identity for this federated identity credential. |
| issuer | string | <input type="checkbox" checked> | None | <pre></pre> | The issuer URL for the federated identity credential. The URL of the issuer to be trusted.<br>Example:<br>'https://token.actions.githubusercontent.com' |
| subject | string | <input type="checkbox" checked> | None | <pre></pre> | The subject claim for the federated identity credential. <br>When used for Connecting a Github account, it is the concatenation of the GitHub organisation, the repository and the entity (tag, environment, PR, branch).<br>Example:<br>'repo:<ORG_NAME>/<REPO_NAME>:environment:<EnvironmentTypeName>' |
| audiences | array | <input type="checkbox"> | None | <pre>[<br>  'api://AzureADTokenExchange'<br>]</pre> | The audiences for the federated identity credential. The list of audiences that can appear in the issued token. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| federatedIdentityCredentialsName | string | The name of the created federated identity credential. |
| federatedIdentityCredentialsId | string | The resource ID of the created federated identity credential. |

## Examples
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

## Links
- [Bicep Microsoft.ManagedIdentity/userAssignedIdentities federatedIdentityCredentials](https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/2024-11-30/userassignedidentities/federatedidentitycredentials?pivots=deployment-language-bicep)<br>
- [Configure a user-assigned managed identity to trust an external identity provider](https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation-create-trust-user-assigned-managed-identity?pivots=identity-wif-mi-methods-azp)<br>
- [Use the Azure Login action from GitHub Actions workflows with OpenID Connect](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure-openid-connect)<br>
- [Manually set an Azure Resource Manager workload identity service connection](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/configure-workload-identity?view=azure-devops&tabs=managed-identity)
