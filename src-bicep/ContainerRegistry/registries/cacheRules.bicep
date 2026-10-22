/*
.SYNOPSIS
Creating an Azure Container Registry Cache Rule.
.DESCRIPTION
Creates a cache rule on an existing Azure Container Registry that enables pulling images
from an external registry (e.g., Docker Hub) through the ACR as a cache. This avoids
rate limits and provides a faster, more reliable pull experience.
.EXAMPLE
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
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.ContainerRegistry registries/cacheRules](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/cacherules?pivots=deployment-language-bicep)
- [Azure Container Registry cache feature](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-artifact-cache)
*/

// ================================================= Parameters =================================================

@description('The name of the existing Azure Container Registry to create the cache rule on.')
@minLength(5)
@maxLength(50)
param containerRegistryName string

@description('''
The name of the cache rule. Must be unique within the container registry.
Only alphanumeric characters and hyphens are allowed.
''')
@minLength(5)
@maxLength(50)
param cacheRuleName string

@description('''
The full path to the source repository on the external registry.
Example: 'docker.io/library/nginx', 'docker.io/asciidoctor/docker-asciidoctor', 'mcr.microsoft.com/dotnet/sdk'
''')
param sourceRepository string

@description('''
The repository path within the ACR where cached images will be stored.
Example: 'library/nginx', 'asciidoctor/docker-asciidoctor', 'dotnet/sdk'
''')
param targetRepository string

@description('''
The resource ID of the credential set to use for authenticating to the source registry.
Required for private repositories. Leave empty for public repositories.
''')
param credentialSetResourceId string = ''

// ================================================= Resources =================================================

@description('Reference to the existing Azure Container Registry.')
resource registry 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
  name: containerRegistryName
}

@description('Upsert the cache rule on the Azure Container Registry.')
resource cacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2025-04-01' = {
  parent: registry
  name: cacheRuleName
  properties: {
    sourceRepository: sourceRepository
    targetRepository: targetRepository
    credentialSetResourceId: !empty(credentialSetResourceId) ? credentialSetResourceId : null
  }
}

// ================================================= Outputs =================================================

@description('The resource ID of the cache rule.')
output cacheRuleId string = cacheRule.id

@description('The name of the cache rule.')
output cacheRuleName string = cacheRule.name
