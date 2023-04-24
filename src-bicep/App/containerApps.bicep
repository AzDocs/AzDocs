/*
.SYNOPSIS
Creating a Azure ContainerApp
.DESCRIPTION
Creating a container app with the given specs.
.EXAMPLE
<pre>
module containerApp 'br:contosoregistry.azurecr.io/app/containerapps.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'containerapp')
  params: {
    containerAppName: 'ca-nginxcontainerapp'
    dapr: {}
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    ingressTargetPort: 80
    location: location
    containerAppContainers: [
      {
        image: 'nginx'
        name: 'nginxcontainerapp' //name of the container in the container app.
        resources: {
          cpu: '0.5'
          memory: '1.0Gi'
        }
      }
    ]
    containerAppScale: {
      minReplicas: 1
      maxReplicas: 1
    }
  }
}
</pre>
<p>Creates a container app with the name ca-nginxcontainerapp'</p>
.LINKS
- [Bicep Microsoft.App containerApps](https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('''
Sets the identity property for the vault
Examples:
{
  type: 'UserAssigned'
  userAssignedIdentities: {}
},
{
  type: 'SystemAssigned'
}
''')
param identity object = {
  type: 'SystemAssigned'
}

@description('The name of the container app. Should be unique per resourcegroup')
@minLength(2)
@maxLength(32)
param containerAppName string

@description('Name of the managed environment the container app should be in. Should be pre-existing.')
@minLength(2)
@maxLength(126)
param managedEnvironmentName string

@description('''
Dapr object. Dapr can be used for state store. This component should be pre-existing.
In the Container App resource, the daprId should match the scopes property within the dapr component being defined
Example:
{
  enabled: true
  appId: 'nodeapp'
  appProtocol: 'http'
  appPort: 3000
}
''')
param dapr object = {}

@description('''
The containers you want to run in your container app.
Examples:
[
  {
    image: 'myacr.azurecr.io/customimagecontainerapp:latest'
    name: 'customimagecontainerapp'
    resources: {
      cpu: '0.5'
      memory: '1.0Gi'
    }
  }
],
[
  {
    image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
    name: 'simple-hello-world-container'
  }
],
[
  {
    image: '${dockerContainerRepository}/someprivatedockerhubimage:tag'
    volumeMounts: [
      {
        mountPath: '/azurefiles'
        volumeName: 'azurefilemount'
      }
    ]
    env: [
      {
        name: 'KEY_VAULT_NAME'
        value: keyVaultName
      }
      {
        name: 'SECRET_NAME'
        value: secretName
      }
      {
        name: 'AZURE_CLIENT_ID'
        value: reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentity.name)).clientId
      }
    ]
    name: 'someprivatedockerhubimage'
    resources: {
      cpu: '0.5'
      memory: '1.0Gi'
    }
  }
]
''')
param containerAppContainers array

@description('''
The scaling for the containers in the container app.
Example:
{
  minReplicas: minReplica
  maxReplicas: maxReplica
  rules: [
    {
      name: 'http-requests'
      http: {
        metadata: {
          concurrentRequests: '10'
        }
      }
    }
  ]
}
''')
param containerAppScale object = {
  minReplicas: 1
  maxReplicas: 1
}

@description('''
ActiveRevisionsMode controls how active revisions are handled for the Container app:
{list}{item}Multiple: multiple revisions can be active.{/item}{item}Single: Only one revision can be active at a time.Revision weights can not be used in this mode.
''')
@allowed([
  'Single'
  'Multiple'
])
param activeRevisionsMode string = 'Single'

@description('''
Collection of private container registry credentials for containers used by the Container app.
If you want to use a public image you do not need to specify any registries, it will be pulled from DockerHub automatically.
Example:
[
  {
  server: myacr.azurecr.io
  username: azureContainerRegistryUsername
  passwordSecretRef: 'containerregistrypasswordref'
  }
]
''')
param registries array = []

@description('''
Collection of secrets used by a Container app. Use with @secure() decorator in modules i.c.w variables, parameters or keyvault.
Examples:
[
  {
    name: 'containerregistrypasswordref'
    value: azureContainerRegistryPassword
  }
],
[
  {
    server: 'index.docker.io'
    username: dockerContainerRegistryUsername
    passwordSecretRef: 'containerregistrypasswordref'
  }
]
''')
param secrets array = []

@description('User friendly suffix that is appended to the revision name')
param revisionSuffix string = ''

@description('''
List of volume definitions for the Container App.
Example:
[
  {
    name: 'azurefilemount'
    // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type#within-parent-resource
    storageName: environment::azurefilestorage.name
    storageType: 'AzureFile'
  }
]
''')
param volumes array = []

@description('''
Bool indicating if HTTP connections to is allowed.
If set to false HTTP connections are automatically redirected to HTTPS connections
''')
param ingressAllowInsecure bool = false

@description('''
Custom domain bindings for Container Apps' hostnames.
Example:
[
  {
    bindingType: 'string'
    certificateId: 'string'
    name: 'string'
  }
]
''')
param ingressCustomDomains array = []

@description('''
Bool indicating if app exposes an external http endpoint.
For applications that need to be accessed from external clients (eg., browsers, other clients, applications hosted somewhere else)
 - set external in ingress to true
''')
param ingressExternal bool = true

@description('''
Target incoming Port in containers for incoming traffic (ingress). This will be the exposed port for the Docker Image.
The ingress section of the container app must have a targetPort specified. TargetPort must be in the range of [1,65535].
''')
@minValue(1)
@maxValue(65535)
param ingressTargetPort int = 80

@description('''
Traffic weights for app's revisions.
Example:
[
  {
    label: 'mylabel'
    latestRevision: true
    weight: 100
  }
]
''')
param ingressTraffic array = [
  {
    weight: 100
    latestRevision: true
  }
]

@description('Ingress transport protocol')
@allowed([
  'auto'
  'http'
  'http2'
])
param ingressTransport string = 'auto'

@description('The name of the existing container app workload profile. If used, it should be pre-existing in the managed environment.')
param workloadProfileName string = ''


@description('the managed environment of the container app. Should be pre-existing')
#disable-next-line BCP081 //preview version used because of support byo vnet with /27 subnet with workload profiles
resource managedEnvironment 'Microsoft.App/managedEnvironments@2022-11-01-preview' existing = {
  name: managedEnvironmentName
}

@description('The container app resource')
#disable-next-line BCP081 //preview version used because of support byo vnet with /27 subnet with workload profiles
resource containerApp 'Microsoft.App/containerApps@2022-11-01-preview' = {
  name: containerAppName
  location: location
  tags: tags
  identity: identity
  properties: {
    configuration: {
      activeRevisionsMode: activeRevisionsMode
      dapr: dapr
      ingress: {
        allowInsecure: ingressAllowInsecure
        customDomains: ingressCustomDomains
        external: ingressExternal
        targetPort: ingressTargetPort
        traffic: ingressTraffic
        transport: ingressTransport
      }
      registries: registries
      secrets: secrets
    }
    managedEnvironmentId: managedEnvironment.id
    template: {
      containers: containerAppContainers
      scale: containerAppScale
      revisionSuffix: revisionSuffix
      volumes: volumes
    }
    workloadProfileName: workloadProfileName
  }
}

@description('Output of the FQDN of the container App.')
output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
