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

//@description('The containers within the container group.')
type container = {
  //@description('The name of the container.')
  @minLength(1)
  name: string

  //@description('The properties of the container.')
  properties: {
    // @description('The command to be executed within the container.')
    // command: containerCommand[] // Command to run inside the container (overrides container entrypoint)

    //@description('The command to be executed within the container.')
    command: string[] // Command to run inside the container (overrides container entrypoint)

    // @description('The environment variables for the container.')
    // environmentVariables: environmentVariable[]? // Optional environment variables

    // @description('The image to be used for the container.')
    // @minLength(1)
    // image: string // Docker image reference (e.g., mcr.microsoft.com/azuredocs/aci-helloworld:latest)

    // @description('The liveness probe configuration for the container.')
    // livenessProbe: containerProbe? // Health check to determine if container is alive

    // @description('The ports to be exposed by the container.')
    // ports: containerPort[]? // Container ports to expose

    // @description('The readiness probe configuration for the container.')
    // readinessProbe: containerProbe? // Health check to determine if container is ready to serve traffic

    // @description('The resource requirements for the container.')
    // resources: resourceRequirements // CPU, memory, and optional GPU requirements

    // @description('The security context for the container.')
    // securityContext: securityContextDefinition? // Security settings for the container

    // @description('The volume mounts for the container.')
    // volumeMounts: volumeMount[]? // Volumes to be mounted inside the container
  }
}

// @description('An optional array of initialization container definitions to be used in the container instance.')
// param initContainers initContainerDefinition[]?

// @description('The init containers for a container group.')
// type initContainerDefinition = {
//   @description('The name of the init container.')
//   @minLength(1)
//   name: string

//   @description('The properties of the init container.')
//   properties: {
//     @description('The command to be executed within the init container.')
//     command: containerCommand[]? // Command to run inside the init container

//     @description('The environment variables for the init container.')
//     environmentVariables: environmentVariable[]? // Optional environment variables

//     @description('The image to be used for the init container.')
//     @minLength(1)
//     image: string // Docker image reference for the init container

//     @description('The security context for the init container.')
//     securityContext: securityContextDefinition? // Security settings for the init container

//     @description('The volume mounts for the init container.')
//     volumeMounts: volumeMount[]? // Volumes to be mounted inside the init container
//   }
// }

// @description('Specifies the command to be executed within the container. This must be a non-empty string.')
// @minLength(1)
// type containerCommand = string

// @description('An optional array of environment variables to be set for the container instance.')
// type environmentVariable = {
//   @description('The name of the resource. Must be at least 1 character long.')
//   @minLength(1)
//   name: string

//   @description('A sensitive value that should be passed in as a secure parameter.')
//   @secure()
//   secureValue: string?

//   @description('A reference to the secure value.')
//   secureValueReference: string?

//   @description('A non-sensitive value.')
//   value: string?
// }

// @description('The container probe configuration used to define liveness, readiness, or startup probes for the container instance.')
// type containerProbe = {
//   @description('The execution command to probe. When not provide, httGet is mandatory.')
//   exec: {
//     @description('Specifies the command to be executed for the container probe. Must be a non-empty string.')
//     @minLength(1)
//     command: string[]
//   }?

//   @description('The failure threshold.')
//   failureThreshold: int

//   @description('The Http Get settings to probe. When not provide, exec is mandatory.')
//   httpGet: {
//     httpHeaders: {
//       @description('The name of the HTTP header.')
//       @minLength(1)
//       name: string

//       @description('The value of the HTTP header.')
//       @minLength(1)
//       value: string
//     }[]?

//     @description('The path to be used in the HTTP GET request.')
//     path: string

//     @description('The port number to probe.')
//     port: int

//     @description('The scheme to be used for the HTTP GET request.')
//     scheme: 'http' | 'https'
//   }

//   @description('The initial delay seconds.')
//   initialDelaySeconds: int

//   @description('The period seconds.')
//   periodSeconds: int

//   @description('The success threshold.')
//   successThreshold: int

//   @description('The timeout seconds.')
//   timeoutSeconds: int
// }

// @description('An optional array of container port objects that define the ports to be exposed by the container instance.')
// type containerPort = {
//   @description('The port number exposed within the container group.')
//   @minValue(1)
//   @maxValue(65535)
//   port: int

//   @description('The protocol associated with the port.')
//   protocol: 'TCP' | 'UDP'
// }

// @description('The resource requirements of the container instance.')
// type resourceRequirements = {
//   @description('The resource limits or maximum of this container instance.')
//   limits: {
//     @description('The CPU core count for the container instance.')
//     cpu: int

//     @description('The GPU resource requirements for the container instance.')
//     gpu: {
//       @description('The count of the GPU resource.')
//       count: int

//       @description('The SKU of the GPU resource.')
//       sku: 'K80' | 'P100' | 'V100'
//     }?

//     @description('The memory size in GB for the container instance.')
//     memoryInGB: int
//   }?

//   @description('The resource requests of this container instance.')
//   requests: {
//     @description('The CPU core count for the container instance.')
//     cpu: int

//     @description('The GPU resource requirements for the container instance.')
//     gpu: {
//       @description('The number of GPUs required.')
//       count: int

//       @description('The SKU of the GPU.')
//       sku: string
//     }?

//     @description('The memory size in GB for the container instance.')
//     memoryInGB: int
//   }
// }

// @description('The container security properties.')
// type securityContextDefinition = {
//   @description('A boolean value indicating whether the init process can elevate its privileges.')
//   allowPrivilegeEscalation: bool

//   @description('The capabilities to add or drop from a container.')
//   capabilities: {
//     @description('The capabilities to add to the container.')
//     add: string[]

//     @description('The capabilities to drop from the container.')
//     drop: string[]
//   }

//   @description('The flag to determine if the container permissions is elevated to Privileged.')
//   privileged: bool

//   @description('Sets the User GID for the container.')
//   runAsGroup: int

//   @description('Sets the User UID for the container.')
//   runAsUser: int

//   @description('A base64 encoded string containing the contents of the JSON in the seccomp profile.')
//   seccompProfile: string
// }

// @description('The volume mounts available to the container instance.')
// type volumeMount = {
//   @description('The path within the container where the volume should be mounted. Must not contain colon (:).')
//   @minLength(1)
//   mountPath: string

//   @description('The name of the volume mount.')
//   @minLength(1)
//   name: string

//   @description('The flag indicating whether the volume mount is read-only.')
//   readOnly: bool
// }

// @description('Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/containergroups?pivots=deployment-language-bicep).')
// param identity object = {
//   type: 'SystemAssigned'
// }

// @description('Specifies the Log Analytics configuration for the container instance.')
// param containerInstanceLogAnalytics containerGroupDiagnostics?

// type containerGroupDiagnostics = {
//   @description('Container group log analytics information.')
//   logAnalytics: logAnalytics
// }

// @description('The diagnostic information for a container group.')
// type logAnalytics = {
//   @description('''The log type to be used.

//   `ContainerInsights`: 
//   This option is part of Azure Monitor and provides comprehensive monitoring capabilities for containers. It collects performance metrics, inventory data, and health state information from container hosts and containers. The data is collected every three minutes and forwarded to the Log Analytics workspace in Azure Monitor. It supports Azure Monitor metrics and provides insights into trends, bottlenecks, and performance optimization.

//   `ContainerInstanceLogs`: 
//   This option focuses on logging and events specific to container instances. It allows you to store and query logging and event data in a centralized location, such as a Log Analytics workspace. This is useful for troubleshooting application errors, identifying and diagnosing application errors or crashes, and analyzing container logs to pinpoint issues.
//   ''')
//   logType: 'ContainerInsights' | 'ContainerInstanceLogs'

//   @description('Metadata for log analytics.')
//   metadata: object?

//   @description('The workspace id for log analytics.')
//   @minLength(1)
//   workspaceId: string

//   @description('The workspace key for log analytics.')
//   @secure()
//   @minLength(1)
//   workspaceKey: string

//   @description('The workspace resource id for log analytics.')
//   @secure()
//   @minLength(1)
//   workspaceResourceId: string
// }

// @description('The DNS configuration for the container instance.')
// param containerInstanceDnsConfig dnsConfiguration?

// @description('The DNS config information for a container group.')
// type dnsConfiguration = {
//   @description('The DNS servers for the container group.')
//   @minLength(1)
//   nameServers: string[]

//   @description('The DNS options for the container group.')
//   options: string?

//   @description('The DNS search domains for hostname lookup in the container group.')
//   searchDomains: string?
// }

// @description('Specifies the encryption properties for the container instance.')
// param containerInstanceEncryptionProperties encryptionProperties?

// @description('The encryption properties for a container group.')
// type encryptionProperties = {
//   @description('The keyvault managed identity.')
//   identity: string

//   @description('The encryption key name.')
//   @minLength(1)
//   keyName: string

//   @description('The encryption key version.')
//   @minLength(1)
//   keyVersion: string

//   @description('The keyvault base url.')
//   @minLength(1)
//   vaultBaseUrl: string
// }

// @description('An array of deployment extension specifications for the container instance.')
// param containerInstanceDeploymentExtension deploymentExtensionSpec[]?

// @description('extensions used by virtual kubelet')
// type deploymentExtensionSpec = {
//   @description('Name of the extension.')
//   name: string

//   @description('Extension specific properties.')
//   properties: {
//     @description('Type of extension to be added.')
//     extensionType: string

//     @description('Protected settings for the extension.')
//     protectedSettings: object

//     @description('Settings for the extension.')
//     settings: object

//     @description('Version of the extension being used.')
//     @minLength(1)
//     version: string
//   }
// }

// @description('Specifies the credentials for the container instance image registry. This is an optional parameter.')
// param containerInstanceImageRegistryCredentials imageRegistryCredential[]?

// @description('The image registry credentials by which the container group is created from.')
// type imageRegistryCredential = {
//   @description('The identity for the private registry.')
//   @minLength(1)
//   identity: string?

//   @description('The identity URL for the private registry.')
//   @minLength(1)
//   identityUrl: string?

//   @description('The password for the private registry.')
//   @secure()
//   @minLength(1)
//   password: string?

//   @description('The reference for the private registry password.')
//   @minLength(1)
//   passwordReference: string?

//   @description('The Docker image registry server without a protocol such as "http" and "https".')
//   @minLength(1)
//   server: string

//   @description('The username for the private registry.')
//   @minLength(1)
//   username: string?
// }

// @description('The IP address configuration for the container instance.')
// param containerInstanceIpAddress ipAddress?

// @description('The IP address type of the container group.')
// type ipAddress = {
//   @description('The value representing the security enum. The "Unsecure" value is the default value if not selected and means the object\'s domain name label is not secured against subdomain takeover. The "TenantReuse" value is the default value if selected and means the object\'s domain name label can be reused within the same tenant. The "SubscriptionReuse" value means the object\'s domain name label can be reused within the same subscription. The "ResourceGroupReuse" value means the object\'s domain name label can be reused within the same resource group. The "NoReuse" value means the object\'s domain name label cannot be reused within the same resource group, subscription, or tenant.')
//   autoGeneratedDomainNameLabelScope:
//     | 'Noreuse'
//     | 'ResourceGroupReuse'
//     | 'SubscriptionReuse'
//     | 'TenantReuse'
//     | 'Unsecure'?

//   @description('The Dns name label for the IP.')
//   dnsNameLabel: string?

//   @description('The IP exposed to the public internet.')
//   ip: string?

//   @description('The list of ports exposed on the container group.')
//   @minLength(1)
//   ports: {
//     @description('The port number.')
//     @minValue(1)
//     @maxValue(65535)
//     port: int

//     @description('The protocol associated with the port.')
//     protocol: 'TCP' | 'UDP'
//   }[]

//   @description('Specifies if the IP is exposed to the public internet or private VNET.')
//   type: 'Private' | 'Public'
// }

// @description('Specifies the operating system type for the container instance. Allowed values are "Linux" and "Windows". Default is "Linux".')
// @allowed([
//   'Linux'
//   'Windows'
// ])
// param osType string = 'Linux'

// @description('Specifies the priority of the container instance. Allowed values are "Regular" and "Spot". Defaults to "Regular".')
// @allowed([
//   'Regular'
//   'Spot'
// ])
// param priority string = 'Regular'

// @description('Specifies the restart policy for the container instance. Allowed values are: Always, OnFailure, Never.')
// @allowed([
//   'Always'
//   'OnFailure'
//   'Never'
// ])
// param restartPolicy string

// @description('An optional array of secret references for the container instance.')
// param containerInstanceSecretReferences secretReference[]?

// @description('The secret references that will be referenced within the container group.')
// type secretReference = {
//   @description('The ARM resource id of the managed identity that has access to the secret in the key vault.')
//   @minLength(1)
//   identity: string

//   @description('The identifier of the secret reference.')
//   @minLength(1)
//   name: string

//   @description('The URI to the secret in key vault.')
//   @minLength(1)
//   secretReferenceUri: string
// }

// @description('Specifies the SKU for the container instance. Allowed values are: Confidential, Dedicated, NotSpecified, and Standard.')
// @allowed([
//   'Confidential'
//   'Dedicated'
//   'NotSpecified'
//   'Standard'
// ])
// param sku string = 'Standard'

// @description('An optional array of subnet IDs for the container group.')
// param containerInstanceSubnetId containerGroupSubnetId[]?

// @description('The subnet resource IDs for a container group.')
// type containerGroupSubnetId = {
//   @description('The resource ID of the virtual network and subnet.')
//   @minLength(1)
//   id: string

//   @description('The friendly name for the subnet.')
//   name: string
// }

// @description('An optional array of container instance volumes to be mounted.')
// param containerInstanceVolume volume[]?

// @description('The list of volumes that can be mounted by containers in this container group.')
// type volume = {
//   @description('The Azure File volume.')
//   azureFile: {
//     @description('The flag indicating whether the Azure File shared mounted as a volume is read-only.')
//     readOnly: bool

//     @description('The name of the Azure File share to be mounted as a volume.')
//     @minLength(1)
//     shareName: string

//     @description('The storage account access key used to access the Azure File share.')
//     @minLength(1)
//     storageAccountKey: string?

//     @description('The reference to the storage account access key used to access the Azure File share.')
//     @minLength(1)
//     storageAccountKeyReference: string?

//     @description('The name of the storage account that contains the Azure File share.')
//     @minLength(1)
//     storageAccountName: string
//   }?

//   @description('The empty directory volume.')
//   emptyDir: object?

//   @description('The git repo volume.')
//   gitRepo: {
//     @description('Target directory name. Must not contain or start with "..". If "." is supplied, the volume directory will be the git repository. Otherwise, if specified, the volume will contain the git repository in the subdirectory with the given name.')
//     @minLength(1)
//     directory: string

//     @description('Repository URL')
//     @minLength(1)
//     repository: string

//     @description('Commit hash for the specified revision.')
//     @minLength(1)
//     revision: string
//   }?

//   @description('The name of the volume.')
//   @minLength(1)
//   name: string
// }

// @description('''
// The tags to apply to this resource. This is an object with key/value pairs.
// Example:
// {
//   FirstTag: myvalue
//   SecondTag: another value
// }
// ''')
// param tags object = {}

// @description('The zones for the container group.')
// param zones string[] = []

// // ================================================= Variables =================================================
// // Configure union of properties based on SKU and other parameters
// var basicProperties = {
//   containers: containers // Required: main container definitions
//   diagnostics: containerInstanceLogAnalytics // Optional: Log Analytics configuration
//   encryptionProperties: containerInstanceEncryptionProperties // Optional: customer-managed keys
//   extensions: containerInstanceDeploymentExtension // Optional: virtual kubelet extensions
//   imageRegistryCredentials: containerInstanceImageRegistryCredentials // Optional: private registry auth
//   initContainers: initContainers // Optional: initialization containers
//   ipAddress: containerInstanceIpAddress // Optional: networking configuration
//   osType: osType // Required: Linux or Windows
//   priority: priority // Required: Regular or Spot
//   restartPolicy: restartPolicy // Required: Always, OnFailure, or Never
//   secretReferences: containerInstanceSecretReferences // Optional: secure values
//   sku: sku // Required: performance tier
//   subnetIds: containerInstanceSubnetId // Optional: connect to VNet
//   volumes: containerInstanceVolume // Optional: persistent storage
// }

// // Additional properties for confidential computing containers
// var confidentialComputeProperty = sku == 'Confidential'
//   ? {
//       confidentialComputeProperties: {
//         ccePolicy: ccePolicy // Applies only when Confidential SKU is selected
//       }
//     }
//   : {}

// // DNS configuration is only added when subnet is configured
// var dnsConfigProperty = !empty(containerInstanceSubnetId) && !empty(containerInstanceDnsConfig)
//   ? {
//       dnsConfig: containerInstanceDnsConfig // Custom DNS for containers in VNet
//     }
//   : {}

// // Merge all property objects together
// var properties = union(basicProperties, confidentialComputeProperty, dnsConfigProperty)

// // ================================================= Resource(s) =================================================

// // Define the Container Instance resource
// resource containerInstance 'Microsoft.ContainerInstance/containerGroups@2024-10-01-preview' = {
//   identity: identity // Managed identity for the container group
//   location: location
//   name: containerInstanceName
//   properties: properties
//   tags: tags // Resource tagging for organization
//   zones: zones // Availability zones for high availability
// }

// // ================================================= Outputs =================================================
// @description('Output the resourceId of the Azure Container Instance')
// output containerInstanceId string = containerInstance.id

output containers container[] = containers
