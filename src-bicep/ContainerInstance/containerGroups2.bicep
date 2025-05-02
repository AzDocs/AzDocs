/*
.SYNOPSIS
Provisioning an Azure Container Instance
.DESCRIPTION
Provisioning an Azure Container Instance.
.KEYFAUTURES
- Support for multiple containers in a container group
- Init containers for setup/teardown processes
- Configurable compute resources (CPU, memory, GPU)
- Volume mounting capabilities
- Network and DNS configuration
- Image registry authentication
- Monitoring and diagnostics integration
- Security features including encryption and secrets management
.EXAMPLE
<pre>
module aci 'br:contosoregistry.azurecr.io/containerinstance/containergroups:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 48), 'containergroups')
  params: {
    ccePolicy: ccePolicy
    containerInstanceDeploymentExtension: containerInstanceDeploymentExtension
    containerInstanceDnsConfig: containerInstanceDnsConfig
    containerInstanceEncryptionProperties: containerInstanceEncryptionProperties
    containerInstanceImageRegistryCredentials: containerInstanceImageRegistryCredentials
    containerInstanceIpAddress: containerInstanceIpAddress
    containerInstanceLogAnalytics: containerInstanceLogAnalytics
    containerInstanceName: containerInstanceName
    containerInstanceSecretReferences: containerInstanceSecretReferences
    containerInstanceSubnetId: containerInstanceSubnetId
    containerInstanceVolume: containerInstanceVolume
    containers: containers
    identity: calculatedIdentity
    initContainers: initContainers
    location: location
    osType: osType
    priority: priority
    restartPolicy: restartPolicy
    sku: sku
    tags: tags
    zones: zones
  }
}
</pre>
<p>Provisioning an Azure Container instance with 1 or more containers</p>
.LINKS
- [Bicep Microsoft.ContainerInstance/containerGroups@2024-10-01-preview](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/2024-10-01-preview/containergroups?pivots=deployment-language-bicep)
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/container-instances/)
*/

// ================================================= Parameters =================================================
@description('An array of container definitions for the container group.')
param containers container[] // At least one container is required

type container = {
  @description('The name of the container.')
  @minLength(1)
  name: string

  @description('The properties of the container.')
  properties: {
    @description('The command to be executed within the container.')
    command: containerCommand[] // Command to run inside the container (overrides container entrypoint)

    @description('The environment variables for the container.')
    environmentVariables: environmentVariable[]? // Optional environment variables

    @description('The liveness probe configuration for the container.')
    livenessProbe: containerProbe? // Health check to determine if container is alive
  }
}

@description('Represents a command to be executed in a container. Must be a non-empty string.')
@minLength(1)
type containerCommand = string

@description('An optional array of environment variables to be set for the container instance.')
type environmentVariable = {
  @description('The name of the resource. Must be at least 1 character long.')
  @minLength(1)
  name: string

  @description('A sensitive value that should be passed in as a secure parameter.')
  @secure()
  secureValue: string?

  @description('A reference to the secure value.')
  secureValueReference: string?

  @description('A non-sensitive value.')
  value: string?
}

@description('The container probe configuration used to define liveness, readiness, or startup probes for the container instance.')
type containerProbe = {
  @description('The execution command to probe. When not provide, httGet is mandatory.')
  exec: {
    @description('Specifies the command to be executed for the container probe. Must be a non-empty string.')
    @minLength(1)
    command: string[]
  }?

  @description('The failure threshold.')
  failureThreshold: int

  @description('The Http Get settings to probe. When not provide, exec is mandatory.')
  httpGet: {
    httpHeaders: {
      @description('The name of the HTTP header.')
      @minLength(1)
      name: string

      @description('The value of the HTTP header.')
      @minLength(1)
      value: string
    }[]?

    @description('The path to be used in the HTTP GET request.')
    path: string

    @description('The port number to probe.')
    port: int

    @description('The scheme to be used for the HTTP GET request.')
    scheme: 'http' | 'https'
  }

  @description('The initial delay seconds.')
  initialDelaySeconds: int

  @description('The period seconds.')
  periodSeconds: int

  @description('The success threshold.')
  successThreshold: int

  @description('The timeout seconds.')
  timeoutSeconds: int
}

output containers array = containers
