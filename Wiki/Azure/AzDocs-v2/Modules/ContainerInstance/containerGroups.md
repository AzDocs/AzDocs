# containerGroups

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="container">container</a>  | <pre>{</pre> |  | The containers within the container group. | 
| <a id="initContainerDefinition">initContainerDefinition</a>  | <pre>{</pre> |  | The init containers for a container group. | 
| <a id="containerCommand">containerCommand</a>  | <pre>string</pre> |  | Specifies the command to be executed within the container. This must be a non-empty string. | 
| <a id="environmentVariable">environmentVariable</a>  | <pre>{</pre> |  | An optional array of environment variables to be set for the container instance. | 
| <a id="containerProbe">containerProbe</a>  | <pre>{</pre> |  | The container probe configuration used to define liveness, readiness, or startup probes for the container instance. | 
| <a id="containerPort">containerPort</a>  | <pre>{</pre> |  | An optional array of container port objects that define the ports to be exposed by the container instance. | 
| <a id="resourceRequirements">resourceRequirements</a>  | <pre>{</pre> |  | The resource requirements of the container instance. | 
| <a id="securityContextDefinition">securityContextDefinition</a>  | <pre>{</pre> |  | The container security properties. | 
| <a id="volumeMount">volumeMount</a>  | <pre>{</pre> |  | The volume mounts available to the container instance. | 
| <a id="containerGroupDiagnostics">containerGroupDiagnostics</a>  | <pre>{</pre> |  | The diagnostics configuration for the container group, including log analytics settings. | 
| <a id="logAnalytics">logAnalytics</a>  | <pre>{</pre> |  | The diagnostic information for a container group. | 
| <a id="dnsConfiguration">dnsConfiguration</a>  | <pre>{</pre> |  | The DNS config information for a container group. | 
| <a id="encryptionProperties">encryptionProperties</a>  | <pre>{</pre> |  | The encryption properties for a container group. | 
| <a id="deploymentExtensionSpec">deploymentExtensionSpec</a>  | <pre>{</pre> |  | extensions used by virtual kubelet | 
| <a id="imageRegistryCredential">imageRegistryCredential</a>  | <pre>{</pre> |  | The image registry credentials by which the container group is created from. | 
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
| containers | container[] | <input type="checkbox" checked> | None | <pre></pre> | An array of container definitions for the container group. At least one container is required |
| initContainers | initContainerDefinition[]? | <input type="checkbox" checked> | None | <pre></pre> | An optional array of initialization container definitions to be used in the container instance. |
| identity | object | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this App Service Instance. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerinstance/containergroups?pivots=deployment-language-bicep). |
| containerInstanceLogAnalytics | containerGroupDiagnostics? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the Log Analytics configuration for the container instance. |
| containerInstanceDnsConfig | dnsConfiguration? | <input type="checkbox" checked> | None | <pre></pre> | The DNS configuration for the container instance. |
| containerInstanceEncryptionProperties | encryptionProperties? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the encryption properties for the container instance. |
| containerInstanceDeploymentExtension | deploymentExtensionSpec[]? | <input type="checkbox" checked> | None | <pre></pre> | An array of deployment extension specifications for the container instance. |
| containerInstanceImageRegistryCredentials | imageRegistryCredential[]? | <input type="checkbox" checked> | None | <pre></pre> | Specifies the credentials for the container instance image registry. This is an optional parameter. |
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
