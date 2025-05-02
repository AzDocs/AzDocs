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
// @description('The name of the Azure Container Instance.')
// @minLength(1)
// param containerInstanceName string // Name must be unique within the resource group

// @description('Specifies the CCE (Cloud Compliance Engine) policy to be applied. This parameter is optional and can be left undefined if no specific policy is required.')
// param ccePolicy string? // Used only with Confidential Computing SKUs

// @description('Location where the azure resource will be deployed')
// @minLength(1)
// param location string = resourceGroup().location // Defaults to resource group location

@description('An array of container definitions for the container group.')
param containers container[] // At least one container is required

// ================================================= Types =================================================
type myType = {
  @description('Name of the person.')
  name: string

  @description('Age of the person.')
  age: int
}

//@description('The containers within the container group.')
type container = {
  //@description('The name of the container.')
  @minLength(1)
  name: string

  //@description('The properties of the container.')
  properties: {
    //@description('The command to be executed within the container.')
    command: string[] // Command to run inside the container (overrides container entrypoint)
  }
}

// ================================================= Outputs =================================================
// @description('The output of the container instance.')
output containers container[] = containers
