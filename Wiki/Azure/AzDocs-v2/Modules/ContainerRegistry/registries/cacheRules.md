# cacheRules

Target Scope: resourceGroup

## Synopsis
Creating an Azure Container Registry Cache Rule.

## Description
Creates a cache rule on an existing Azure Container Registry that enables pulling images<br>
from an external registry (e.g., Docker Hub) through the ACR as a cache. This avoids<br>
rate limits and provides a faster, more reliable pull experience.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| containerRegistryName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the existing Azure Container Registry to create the cache rule on. |
| cacheRuleName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | The name of the cache rule. Must be unique within the container registry.<br>Only alphanumeric characters and hyphens are allowed. |
| sourceRepository | string | <input type="checkbox" checked> | None | <pre></pre> | The full path to the source repository on the external registry.<br>Example: 'docker.io/library/nginx', 'docker.io/asciidoctor/docker-asciidoctor', 'mcr.microsoft.com/dotnet/sdk' |
| targetRepository | string | <input type="checkbox" checked> | None | <pre></pre> | The repository path within the ACR where cached images will be stored.<br>Example: 'library/nginx', 'asciidoctor/docker-asciidoctor', 'dotnet/sdk' |
| credentialSetResourceId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource ID of the credential set to use for authenticating to the source registry.<br>Required for private repositories. Leave empty for public repositories. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| cacheRuleId | string | The resource ID of the cache rule. |
| cacheRuleName | string | The name of the cache rule. |

## Examples
<pre>
module cacheRule 'br:acrazdocsprd.azurecr.io/containerregistry/cacherules:2026.04.14.1-main' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'cacheRuleDeploy')
  params: {
    containerRegistryName: 'myacr'
    cacheRuleName: 'docker-hub-nginx'
    sourceRepository: 'docker.io/library/nginx'
    targetRepository: 'library/nginx'
  }
}
</pre>
<p>Creates a cache rule that caches docker.io/library/nginx as library/nginx in the ACR.</p>
<pre>
module cacheRule 'br:acrazdocsprd.azurecr.io/containerregistry/cacherules:2026.04.14.1-main' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'cacheRuleAuthDeploy')
  params: {
    containerRegistryName: 'myacr'
    cacheRuleName: 'docker-hub-private'
    sourceRepository: 'docker.io/myorg/myimage'
    targetRepository: 'myorg/myimage'
    credentialSetResourceId: '/subscriptions/.../credentialSets/dockerhub-credentials'
  }
}
</pre>
<p>Creates a cache rule with authentication using a credential set for private repositories.</p>

## Links
- [Bicep Microsoft.ContainerRegistry registries/cacheRules](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/cacherules?pivots=deployment-language-bicep)<br>
- [Azure Container Registry cache feature](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-artifact-cache)
