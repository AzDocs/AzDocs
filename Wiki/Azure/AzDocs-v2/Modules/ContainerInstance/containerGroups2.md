# containerGroups2

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="container">container</a>  | <pre>{</pre> |  | The definition of a container within the container group. | 
| <a id="containerCommand">containerCommand</a>  | <pre>string</pre> |  | Represents a command to be executed in a container. Must be a non-empty string. | 
| <a id="environmentVariable">environmentVariable</a>  | <pre>{</pre> |  | An optional array of environment variables to be set for the container instance. | 
| <a id="containerProbe">containerProbe</a>  | <pre>{</pre> |  | The container probe configuration used to define liveness, readiness, or startup probes for the container instance. | 
| <a id="containerPort">containerPort</a>  | <pre>{</pre> |  | An optional array of container port objects that define the ports to be exposed by the container instance. | 
| <a id="resourceRequirements">resourceRequirements</a>  | <pre>{</pre> |  | The resource requirements of the container instance. | 
| <a id="securityContextDefinition">securityContextDefinition</a>  | <pre>{</pre> |  | The container security properties. | 
| <a id="volumeMount">volumeMount</a>  | <pre>{</pre> |  | The volume mounts available to the container instance. | 

## Synopsis
Provisioning an Azure Container Instance

## Description
Provisioning an Azure Container Instance.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| containerInstanceName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the Azure Container Instance. |
| containers | container[] | <input type="checkbox" checked> | None | <pre></pre> | An array of container definitions for the container group. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| containers | array |  |
| containerInstanceName | string |  |

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
