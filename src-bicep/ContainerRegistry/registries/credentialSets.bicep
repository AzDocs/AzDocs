/*
.SYNOPSIS
Creating an Azure Container Registry Credential Set.
.DESCRIPTION
Creates a credential set on an existing Azure Container Registry for authenticating
to external registries (e.g., Docker Hub) when using ACR cache rules. The credential set
references Key Vault secrets for the username and password.
.EXAMPLE
<pre>
module credentialSet 'br:acrazdocsprd.azurecr.io/containerregistry/credentialsets:2026.04.14.1-main' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'credSetDeploy')
  params: {
    containerRegistryName: 'myacr'
    credentialSetName: 'dockerio'
    loginServer: 'docker.io'
    usernameKeyVaultSecretUri: 'https://myvault.vault.azure.net/secrets/dockerio-username'
    passwordKeyVaultSecretUri: 'https://myvault.vault.azure.net/secrets/dockerio-password'
  }
}
</pre>
<p>Creates a credential set for Docker Hub authentication using Key Vault secrets.</p>
.LINKS
- [Bicep Microsoft.ContainerRegistry registries/credentialSets](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/credentialsets?pivots=deployment-language-bicep)
- [Azure Container Registry cache with authentication](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-artifact-cache#configure-credentials)
*/

// ================================================= Parameters =================================================

@description('The name of the existing Azure Container Registry to create the credential set on.')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('The name of the credential set. Must be unique within the container registry.')
@minLength(5)
@maxLength(50)
param credentialSetName string

@description('''
The login server of the external registry to authenticate to.
Example: 'docker.io', 'ghcr.io', 'quay.io'
''')
param loginServer string

@description('''
The Key Vault secret URI that contains the username for the external registry.
Example: 'https://myvault.vault.azure.net/secrets/dockerio-username'
''')
param usernameKeyVaultSecretUri string

@description('''
The Key Vault secret URI that contains the password or access token for the external registry.
Example: 'https://myvault.vault.azure.net/secrets/dockerio-password'
''')
param passwordKeyVaultSecretUri string

@description('The name of the auth credential entry. Defaults to Credential1.')
param authCredentialName string = 'Credential1'

@description('Managed service identity used for authorization against the Key Vault. Defaults to a system assigned managed identity.')
param identity object = {
  type: 'SystemAssigned'
}

// ================================================= Resources =================================================

@description('Reference to the existing Azure Container Registry.')
resource registry 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
  name: containerRegistryName
}

@description('Upsert the credential set on the Azure Container Registry.')
resource credentialSet 'Microsoft.ContainerRegistry/registries/credentialSets@2025-04-01' = {
  parent: registry
  name: credentialSetName
  identity: identity
  properties: {
    loginServer: loginServer
    authCredentials: [
      {
        name: authCredentialName
        usernameSecretIdentifier: usernameKeyVaultSecretUri
        passwordSecretIdentifier: passwordKeyVaultSecretUri
      }
    ]
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the credential set.')
output credentialSetId string = credentialSet.id

@description('The name of the credential set.')
output credentialSetName string = credentialSet.name

@description('The principal ID of the system-assigned managed identity for Key Vault access.')
output principalId string = credentialSet.identity.principalId
