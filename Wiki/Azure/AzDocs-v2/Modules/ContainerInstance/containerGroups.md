# containerGroups

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="ipAddress">ipAddress</a>  | <pre>{</pre> |  | The IP address type of the container group. | 
| <a id="secretReference">secretReference</a>  | <pre>{</pre> |  | The secret references that will be referenced within the container group. | 
| <a id="containerGroupSubnetId">containerGroupSubnetId</a>  | <pre>{</pre> |  | The subnet resource IDs for a container group. | 
| <a id="volume">volume</a>  | <pre>{</pre> |  | The list of volumes that can be mounted by containers in this container group. | 

## Synopsis
Provisioning an Azure Container Instance

## Description
Provisioning an Azure Container Instance.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| containerInstanceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the Azure Container Instance. |
| ccePolicy | string? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the CCE (Cloud Compliance Engine) policy to be applied. This parameter is optional and can be left undefined if no specific policy is required. |
| location | string | <input type="checkbox"> | Length between 1-* | <pre>resourceGroup().location</pre> | Location where the azure resource will be deployed. Defaults to resource group location |
| containers | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.containers | <input type="checkbox" checked> | None | <pre></pre> | An array of container definitions for the container group. At least one container is required |
| initContainers | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.initContainers? | <input type="checkbox" checked> | None | <pre></pre> | An optional array of initialization container definitions to be used in the container instance. |
| identity | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.identity | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this resource. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/containergroups?pivots=deployment-language-bicep). |
| containerInstanceLogAnalytics | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.diagnostics? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the Log Analytics configuration for the container instance. |
| containerInstanceDnsConfig | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.dnsConfig? | <input type="checkbox" checked> | None | <pre></pre> | The DNS configuration for the container instance. |
| containerInstanceEncryptionProperties | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.encryptionProperties? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the encryption properties for the container instance. |
| containerInstanceDeploymentExtension | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.extensions? | <input type="checkbox" checked> | None | <pre></pre> | An array of deployment extension specifications for the container instance. |
| containerInstanceImageRegistryCredentials | resourceInput<'Microsoft.ContainerInstance/containerGroups@2025-09-01'>.properties.imageRegistryCredentials? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the credentials for the container instance image registry. This is an optional parameter. |
| containerInstanceIpAddress | ipAddress? | <input type="checkbox" checked> | None | <pre></pre> | The IP address configuration for the container instance. |
| osType | string | <input type="checkbox"> | `'Linux'` or `'Windows'` | <pre>'Linux'</pre> | Specifies the operating system type for the container instance. Allowed values are "Linux" and "Windows". Default is "Linux". |
| priority | string | <input type="checkbox"> | `'Regular'` or `'Spot'` | <pre>'Regular'</pre> | Specifies the priority of the container instance. Allowed values are "Regular" and "Spot". Defaults to "Regular". |
| restartPolicy | string | <input type="checkbox" checked> | `'Always'` or `'OnFailure'` or `'Never'` | <pre></pre> | Specifies the restart policy for the container instance. Allowed values are: Always, OnFailure, Never. |
| containerInstanceSecretReferences | secretReference[]? | <input type="checkbox" checked> | None | <pre></pre> | An optional array of secret references for the container instance. |
| sku | string | <input type="checkbox"> | `'Confidential'` or `'Dedicated'` or `'NotSpecified'` or `'Standard'` | <pre>'Standard'</pre> | Specifies the SKU for the container instance. Allowed values are: Confidential, Dedicated, NotSpecified, and Standard. |
| containerInstanceSubnetId | containerGroupSubnetId[]? | <input type="checkbox" checked> | None | <pre></pre> | An optional array of subnet IDs for the container group. |
| containerInstanceVolume | volume[]? | <input type="checkbox" checked> | None | <pre></pre> | An optional array of container instance volumes to be mounted. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| zones | string[] | <input type="checkbox"> | None | <pre>[]</pre> | The zones for the container group. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| containerInstanceId | string | Output the resourceId of the Azure Container Instance |

## Examples
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

## Links
- [Bicep Microsoft.ContainerInstance/containerGroups@2024-10-01-preview](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/2024-10-01-preview/containergroups?pivots=deployment-language-bicep)<br>
- [Microsoft Learn](https://learn.microsoft.com/en-us/azure/container-instances/)
