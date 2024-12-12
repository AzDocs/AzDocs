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
    managedEnvironmentName: managedEnvironment.outputs.managedEnvironmentName
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '/subscriptions/8c89ea18-8578-4898-b51e-a4f45f502b0b/resourcegroups/cae-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-kxjo5b6wmgva6': {}
      }
    }
    containerAppName: 'containerapp1'
    containers: [
      {
        name: 'container1'
        image: 'nginx'
        resources: {
          cpu: 1
          memory: '2Gi'
        }
        env: [
          {
            name: 'ENV1'
            value: 'VALUE1'
          }
        ]
      }
    ]
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
Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. 
For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity).
Example:
identity: {
  type: 'None'
},
identity: {
  type: 'UserAssigned'
  userAssignedIdentities: {
    '/subscriptions/<subscriptionId>/resourcegroups/<resourcegroupname>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<userassignedmanagedidentityname>': {}
  }
}
''')
param identity IdentityType = {
  type: 'SystemAssigned'
}

@discriminator('type')
type IdentityType =
  | {
    type: 'SystemAssigned'
  }
  | {
    type: 'UserAssigned'
    userAssignedIdentities: {
      *: {}
    }
  }
  | {
    type: 'None'
  }

@description('The name of the container app. Should be unique per resourcegroup')
@minLength(2)
@maxLength(32)
param containerAppName string

@description('Name of the managed environment the container app should be in. Should be pre-existing.')
@minLength(2)
@maxLength(126)
param managedEnvironmentName string

@description('Optional. Bool to disable all ingress traffic for the container app.')
param disableIngress bool = false

@description('''
Optional extra tcp ports. Settings to expose additional ports on container app. AdditionalPortMappings must have unique exposedPort and TargetPort.
Applications with external additional port mappings can only be deployed to Container App Environments that have a custom VNET
Example:
additionalPortMappings: [
  {
    exposedPort: 8081
    external: true
    targetPort: 8080
  }
]
''')
param additionalPortMappings ingressPortMapping[]?

type ingressPortMapping = {
  @description('Optional. Specifies the exposed port for the target port. If not specified, it defaults to target port.')
  exposedPort: int?

  @description('Required. Specifies whether the app port is accessible outside of the environment.')
  external: bool

  @description('Required. Specifies the port the container listens on.')
  targetPort: int
}

@description('Optional. Object userd to configure CORS policy.')
param corsPolicy corsPolicyType

type corsPolicyType = {
  @description('Optional. Switch to determine whether the resource allows credentials.')
  allowCredentials: bool?

  @description('Optional. Specifies the content for the access-control-allow-headers header.')
  allowedHeaders: string[]?

  @description('Optional. Specifies the content for the access-control-allow-methods header.')
  allowedMethods: string[]?

  @description('Optional. Specifies the content for the access-control-allow-origins header.')
  allowedOrigins: string[]?

  @description('Optional. Specifies the content for the access-control-expose-headers header.')
  exposeHeaders: string[]?

  @description('Optional. Specifies the content for the access-control-max-age header.')
  maxAge: int?
}?

@allowed([
  'accept'
  'ignore'
  'require'
])
@description('Optional. Client certificate mode for mTLS.')
param clientCertificateMode string = 'ignore'

@description('Optional. Exposed Port in containers for TCP traffic from ingress.')
param exposedPort int = 0

@description('Optional. Rules to restrict incoming IP address.')
param ipSecurityRestrictions array = []

@allowed([
  'none'
  'sticky'
])
@description('Optional. Bool indicating if the Container App should enable session affinity.')
param stickySessionsAffinity string = 'none'

@description('Optional. Associates a traffic label with a revision. Label name should be consist of lower case alphanumeric characters or dashes.')
param trafficLabel string = 'label1'

@description('Optional. Indicates that the traffic weight belongs to a latest stable revision.')
param trafficLatestRevision bool = true

@description('Optional. Name of a revision.')
param trafficRevisionName string = ''

@description('Optional. Traffic weight assigned to a revision.')
param trafficWeight int = 100

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
@secure()
param secrets object = {}

var secretList = !empty(secrets) ? secrets.secureList : []

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

@description('Ingress transport protocol')
@allowed([
  'auto'
  'http'
  'http2'
  'tcp'
])
param ingressTransport string = 'auto'

@description('The name of the existing container app workload profile. If used, it should be pre-existing in the managed environment.')
param workloadProfileName string = ''

@description('Optional. Toggle to include the service configuration.')
param includeAddOns bool = false

@description('Optional. Dev ContainerApp service type.')
param service object = {}

@description('Optional. Max inactive revisions a Container App can have.')
param maxInactiveRevisions int = 0

@description('''
Required. List of container definitions for the Container App.
Example:
[
  {
    image: 'nginx'
    name: 'nginxcontainerapp'
    resources: {
      cpu: '0.5'
      memory: '1.0Gi'
    }
  },
  {
  image: 'myacr.azurecr.io/customimagecontainerapp:latest'
  name: 'customimagecontainerapp'
  resources: {
    cpu: '0.5'
    memory: '1.0Gi'
  }
},
{
  image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
  name: 'simple-hello-world-container'
  resources: {
    cpu: '0.5'
    memory: '1.0Gi'
  }
},
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
param containers container[]

type container = {
  @description('Optional. Container start command arguments.')
  args: string[]?

  @description('Optional. Container start command.')
  command: string[]?

  @description('Optional. Container environment variables.')
  env: environmentVar[]?

  @description('Required. Container image tag.')
  image: string

  @description('''
  Optional. Custom container name. A name must consist of lower case alphanumeric characters or -, start with an alphabetic character, and end with an alphanumeric character and cannot have --. 
  The length must not be more than 32 characters.
  ''')
  name: string?

  @description('Optional. List of probes for the container.')
  probes: containerAppProbe[]?

  @description('Required. Container resource requirements.Total CPU and memory for all containers defined in a Container App must add up to allowed CPU - Memory combinations like [cpu: 0.25, memory: 0.5Gi]')
  resources: object

  @description('Optional. Container volume mounts.')
  volumeMounts: volumeMount[]?
}

type environmentVar = {
  @description('Required. Environment variable name.')
  name: string

  @description('Optional. Name of the Container App secret from which to pull the environment variable value.')
  secretRef: string?

  @description('Optional. Non-secret environment variable value.')
  value: string?
}

type containerAppProbe = {
  @description('Optional. Minimum consecutive failures for the probe to be considered failed after having succeeded. Defaults to 3.')
  @minValue(1)
  @maxValue(10)
  failureThreshold: int?

  @description('Optional. HTTPGet specifies the http request to perform.')
  httpGet: containerAppProbeHttpGet?

  @description('Optional. Number of seconds after the container has started before liveness probes are initiated.')
  @minValue(1)
  @maxValue(60)
  initialDelaySeconds: int?

  @description('Optional. How often (in seconds) to perform the probe. Default to 10 seconds.')
  @minValue(1)
  @maxValue(240)
  periodSeconds: int?

  @description('Optional. Minimum consecutive successes for the probe to be considered successful after having failed. Defaults to 1. Must be 1 for liveness and startup.')
  @minValue(1)
  @maxValue(10)
  successThreshold: int?

  @description('Optional. TCPSocket specifies an action involving a TCP port. TCP hooks not yet supported.')
  tcpSocket: containerAppProbeTcpSocket?

  @description('Optional. Optional duration in seconds the pod needs to terminate gracefully upon probe failure. The grace period is the duration in seconds after the processes running in the pod are sent a termination signal and the time when the processes are forcibly halted with a kill signal. Set this value longer than the expected cleanup time for your process. If this value is nil, the pod\'s terminationGracePeriodSeconds will be used. Otherwise, this value overrides the value provided by the pod spec. Value must be non-negative integer. The value zero indicates stop immediately via the kill signal (no opportunity to shut down). This is an alpha field and requires enabling ProbeTerminationGracePeriod feature gate. Maximum value is 3600 seconds (1 hour).')
  terminationGracePeriodSeconds: int?

  @description('Optional. Number of seconds after which the probe times out. Defaults to 1 second.')
  @minValue(1)
  @maxValue(240)
  timeoutSeconds: int?

  @description('Optional. The type of probe.')
  type: ('Liveness' | 'Startup' | 'Readiness')?
}

type volumeMount = {
  @description('Required. Path within the container at which the volume should be mounted.Must not contain \':\'.')
  mountPath: string

  @description('Optional. Path within the volume from which the container\'s volume should be mounted. Defaults to "" (volume\'s root).')
  subPath: string?

  @description('Required. This must match the Name of a Volume.')
  volumeName: string
}

type containerAppProbeHttpGet = {
  @description('Optional. Host name to connect to. Defaults to the pod IP.')
  host: string?

  @description('Optional. HTTP headers to set in the request.')
  httpHeaders: containerAppProbeHttpGetHeadersItem[]?

  @description('Required. Path to access on the HTTP server.')
  path: string

  @description('Required. Name or number of the port to access on the container.')
  port: int

  @description('Optional. Scheme to use for connecting to the host. Defaults to HTTP.')
  scheme: ('HTTP' | 'HTTPS')?
}

type containerAppProbeHttpGetHeadersItem = {
  @description('Required. Name of the header.')
  name: string

  @description('Required. Value of the header.')
  value: string
}

type containerAppProbeTcpSocket = {
  @description('Optional. Host name to connect to, defaults to the pod IP.')
  host: string?

  @description('Required. Number of the port to access on the container. Name must be an IANA_SVC_NAME.')
  @minValue(1)
  @maxValue(65535)
  port: int
}

@description('Optional. List of specialized containers that run before app containers.')
param initContainersTemplate array = []

@description('Optional. Maximum number of container replicas. Defaults to 3 if not set.')
param scaleMaxReplicas int = 3

@description('Optional. Minimum number of container replicas. Defaults to 1 if not set.')
param scaleMinReplicas int = 1

@description('''
Optional. Scaling rules.
Example:
scaleRules: [
  {
    name: 'http-requests'
    http: {
      metadata: {
        concurrentRequests: '10'
      }
    }
  }
]
''')
param scaleRules array = []

@description('Optional. List of container app services bound to the app.')
param serviceBinds serviceBind[]?

type serviceBind = {
  @description('Required. The name of the service.')
  name: string

  @description('Required. The service ID.')
  serviceId: string
}
// ================================================= Resources =================================================

@description('the managed environment of the container app. Should be pre-existing')
resource managedEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: managedEnvironmentName
}

@description('The container app resource')
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  identity: identity
  properties: {
    managedEnvironmentId: managedEnvironment.id
    configuration: {
      activeRevisionsMode: activeRevisionsMode
      dapr: dapr
      ingress: disableIngress
        ? null
        : {
            additionalPortMappings: additionalPortMappings
            allowInsecure: ingressTransport != 'tcp' ? ingressAllowInsecure : false
            customDomains: !empty(ingressCustomDomains) ? ingressCustomDomains : null
            corsPolicy: corsPolicy != null && ingressTransport != 'tcp'
              ? {
                  allowCredentials: corsPolicy.?allowCredentials ?? false
                  allowedHeaders: corsPolicy.?allowedHeaders ?? []
                  allowedMethods: corsPolicy.?allowedMethods ?? []
                  allowedOrigins: corsPolicy.?allowedOrigins ?? []
                  exposeHeaders: corsPolicy.?exposeHeaders ?? []
                  maxAge: corsPolicy.?maxAge
                }
              : null
            clientCertificateMode: ingressTransport != 'tcp' ? clientCertificateMode : null
            exposedPort: exposedPort
            external: ingressExternal
            ipSecurityRestrictions: !empty(ipSecurityRestrictions) ? ipSecurityRestrictions : null
            targetPort: ingressTargetPort
            stickySessions: {
              affinity: stickySessionsAffinity
            }
            traffic: ingressTransport != 'tcp'
              ? [
                  {
                    label: trafficLabel
                    latestRevision: trafficLatestRevision
                    revisionName: trafficRevisionName
                    weight: trafficWeight
                  }
                ]
              : null
            transport: ingressTransport
          }
      service: (includeAddOns && !empty(service)) ? service : null
      maxInactiveRevisions: maxInactiveRevisions
      registries: !empty(registries) ? registries : null
      secrets: secretList
    }
    template: {
      containers: containers
      initContainers: !empty(initContainersTemplate) ? initContainersTemplate : null
      revisionSuffix: revisionSuffix
      scale: {
        maxReplicas: scaleMaxReplicas
        minReplicas: scaleMinReplicas
        rules: !empty(scaleRules) ? scaleRules : null
      }
      serviceBinds: (includeAddOns && !empty(serviceBinds)) ? serviceBinds : null
      volumes: !empty(volumes) ? volumes : null
    }
    workloadProfileName: workloadProfileName
  }
}

// ================================================= Outputs =================================================
@description('Output of the FQDN of the container App.')
output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = containerApp.?identity.?principalId ?? ''
