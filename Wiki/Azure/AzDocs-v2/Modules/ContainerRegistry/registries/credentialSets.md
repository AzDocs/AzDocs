# credentialSets

Target Scope: resourceGroup

## Synopsis
Creating an Azure Container Registry Credential Set.

## Description
Creates a credential set on an existing Azure Container Registry for authenticating<br>
to external registries (e.g., Docker Hub) when using ACR cache rules. The credential set<br>
references Key Vault secrets for the username and password.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| containerRegistryName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the existing Azure Container Registry to create the credential set on. |
| credentialSetName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the credential set. Must be unique within the container registry. |
| loginServer | string | <input type="checkbox" checked> | None | <pre></pre> | The login server of the external registry to authenticate to.<br>Example: 'docker.io', 'ghcr.io', 'quay.io' |
| usernameKeyVaultSecretUri | string | <input type="checkbox" checked> | None | <pre></pre> | The Key Vault secret URI that contains the username for the external registry.<br>Example: 'https://myvault.vault.azure.net/secrets/dockerio-username' |
| passwordKeyVaultSecretUri | string | <input type="checkbox" checked> | None | <pre></pre> | The Key Vault secret URI that contains the password or access token for the external registry.<br>Example: 'https://myvault.vault.azure.net/secrets/dockerio-password' |
| authCredentialName | string | <input type="checkbox"> | None | <pre>'Credential1'</pre> | The name of the auth credential entry. Defaults to Credential1. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity used for authorization against the Key Vault. Defaults to a system assigned managed identity. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| credentialSetId | string | The resource ID of the credential set. |
| credentialSetName | string | The name of the credential set. |
| principalId | string | The principal ID of the system-assigned managed identity for Key Vault access. |

## Examples
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

## Links
- [Bicep Microsoft.ContainerRegistry registries/credentialSets](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/credentialsets?pivots=deployment-language-bicep)<br>
- [Azure Container Registry cache with authentication](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-artifact-cache#configure-credentials)
