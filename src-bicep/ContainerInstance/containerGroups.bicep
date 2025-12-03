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
@description('The name of the Azure Container Instance.')
@minLength(1)
param containerInstanceName string

@description('Specifies the CCE (Cloud Compliance Engine) policy to be applied. This parameter is optional and can be left undefined if no specific policy is required.')
param ccePolicy string?

@description('Location where the azure resource will be deployed. Defaults to resource group location')
@minLength(1)
param location string = resourceGroup().location

@description('An array of container definitions for the container group. At least one container is required')
param containers resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.containers

@description('An optional array of initialization container definitions to be used in the container instance.')
param initContainers resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.initContainers?

@description('Managed service identity to use for this resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/containergroups?pivots=deployment-language-bicep).')
param identity resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.identity = {
  type: 'SystemAssigned'
}

@description('Specifies the Log Analytics configuration for the container instance.')
param containerInstanceLogAnalytics resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.diagnostics?

@description('The DNS configuration for the container instance.')
param containerInstanceDnsConfig resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.dnsConfig?


@description('Specifies the encryption properties for the container instance.')
param containerInstanceEncryptionProperties resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.encryptionProperties?


@description('An array of deployment extension specifications for the container instance.')
param containerInstanceDeploymentExtension  resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.extensions?


@description('Specifies the credentials for the container instance image registry. This is an optional parameter.')
param containerInstanceImageRegistryCredentials  resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.imageRegistryCredentials?

@description('The IP address configuration for the container instance.')
param containerInstanceIpAddress ipAddress?

@description('The IP address type of the container group.')
type ipAddress = {
  @description('The value representing the security enum. The "Unsecure" value is the default value if not selected and means the object\'s domain name label is not secured against subdomain takeover. The "TenantReuse" value is the default value if selected and means the object\'s domain name label can be reused within the same tenant. The "SubscriptionReuse" value means the object\'s domain name label can be reused within the same subscription. The "ResourceGroupReuse" value means the object\'s domain name label can be reused within the same resource group. The "NoReuse" value means the object\'s domain name label cannot be reused within the same resource group, subscription, or tenant.')
  autoGeneratedDomainNameLabelScope:
    | 'Noreuse'
    | 'ResourceGroupReuse'
    | 'SubscriptionReuse'
    | 'TenantReuse'
    | 'Unsecure'?

  @description('The Dns name label for the IP.')
  dnsNameLabel: string?

  @description('The IP exposed to the public internet.')
  ip: string?

  @description('The list of ports exposed on the container group.')
  @minLength(1)
  ports: {
    @description('The port number.')
    @minValue(1)
    @maxValue(65535)
    port: int

    @description('The protocol associated with the port.')
    protocol: 'TCP' | 'UDP'
  }[]

  @description('Specifies if the IP is exposed to the public internet or private VNET.')
  type: 'Private' | 'Public'
}

@description('Specifies the operating system type for the container instance. Allowed values are "Linux" and "Windows". Default is "Linux".')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('Specifies the priority of the container instance. Allowed values are "Regular" and "Spot". Defaults to "Regular".')
@allowed([
  'Regular'
  'Spot'
])
param priority string = 'Regular'

@description('Specifies the restart policy for the container instance. Allowed values are: Always, OnFailure, Never.')
@allowed([
  'Always'
  'OnFailure'
  'Never'
])
param restartPolicy string

@description('An optional array of secret references for the container instance.')
param containerInstanceSecretReferences secretReference[]?

@description('The secret references that will be referenced within the container group.')
type secretReference = {
  @description('The ARM resource id of the managed identity that has access to the secret in the key vault.')
  @minLength(1)
  identity: string

  @description('The identifier of the secret reference.')
  @minLength(1)
  name: string

  @description('The URI to the secret in key vault.')
  @minLength(1)
  secretReferenceUri: string
}

@description('Specifies the SKU for the container instance. Allowed values are: Confidential, Dedicated, NotSpecified, and Standard.')
@allowed([
  'Confidential'
  'Dedicated'
  'NotSpecified'
  'Standard'
])
param sku string = 'Standard'

@description('An optional array of subnet IDs for the container group.')
param containerInstanceSubnetId containerGroupSubnetId[]?

@description('The subnet resource IDs for a container group.')
type containerGroupSubnetId = {
  @description('The resource ID of the virtual network and subnet.')
  @minLength(1)
  id: string

  @description('The friendly name for the subnet.')
  name: string
}

@description('An optional array of container instance volumes to be mounted.')
param containerInstanceVolume volume[]?

@description('The list of volumes that can be mounted by containers in this container group.')
type volume = {
  @description('The Azure File volume.')
  azureFile: {
    @description('The flag indicating whether the Azure File shared mounted as a volume is read-only.')
    readOnly: bool

    @description('The name of the Azure File share to be mounted as a volume.')
    @minLength(1)
    shareName: string

    @description('The storage account access key used to access the Azure File share.')
    @minLength(1)
    storageAccountKey: string?

    @description('The reference to the storage account access key used to access the Azure File share.')
    @minLength(1)
    storageAccountKeyReference: string?

    @description('The name of the storage account that contains the Azure File share.')
    @minLength(1)
    storageAccountName: string
  }?

  @description('The empty directory volume.')
  emptyDir: object?

  @description('The git repo volume.')
  gitRepo: {
    @description('Target directory name. Must not contain or start with "..". If "." is supplied, the volume directory will be the git repository. Otherwise, if specified, the volume will contain the git repository in the subdirectory with the given name.')
    @minLength(1)
    directory: string

    @description('Repository URL')
    @minLength(1)
    repository: string

    @description('Commit hash for the specified revision.')
    @minLength(1)
    revision: string
  }?

  @description('The name of the volume.')
  @minLength(1)
  name: string
}

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The zones for the container group.')
param zones string[] = []

// ================================================= Variables =================================================
// Configure union of properties based on SKU and other parameters
// var basicProperties = {
//   containers: containers
//   diagnostics: containerInstanceLogAnalytics
//   encryptionProperties: containerInstanceEncryptionProperties
//   extensions: containerInstanceDeploymentExtension
//   imageRegistryCredentials: containerInstanceImageRegistryCredentials
//   initContainers: initContainers
//   ipAddress: containerInstanceIpAddress
//   osType: osType
//   priority: priority
//   restartPolicy: restartPolicy
//   secretReferences: containerInstanceSecretReferences
//   sku: sku
//   subnetIds: containerInstanceSubnetId
//   volumes: containerInstanceVolume
// }

var confidentialComputeProperty = sku == 'Confidential'
  ? {
      confidentialComputeProperties: {
        ccePolicy: ccePolicy
      }
    }
  : {}

var dnsConfigProperty = !empty(containerInstanceSubnetId) && !empty(containerInstanceDnsConfig)
  ? {
      dnsConfig: containerInstanceDnsConfig
    }
  : {}

// var properties = union(basicProperties, confidentialComputeProperty, dnsConfigProperty)





var properties = {
  volumes: containerInstanceVolume
  containers: containers
  diagnostics: containerInstanceLogAnalytics
  encryptionProperties: containerInstanceEncryptionProperties
  extensions: containerInstanceDeploymentExtension
  imageRegistryCredentials: containerInstanceImageRegistryCredentials
  initContainers: initContainers
  ipAddress: containerInstanceIpAddress
  osType: osType
  priority: priority
  restartPolicy: restartPolicy
  secretReferences: containerInstanceSecretReferences
  sku: sku
  subnetIds: containerInstanceSubnetId
}

var propertiesFinal = union(properties, confidentialComputeProperty, dnsConfigProperty)


// ================================================= Resource(s) =================================================
resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2025-09-01' = {
  identity: identity
  location: location
  name: containerInstanceName
  properties: propertiesFinal
  tags: tags
  zones: zones
}

// ================================================= Outputs =================================================
@description('Output the resourceId of the Azure Container Instance')
output containerInstanceId string = containerInstance.id
