# agentPools

Target Scope: resourceGroup

## Synopsis
Creating a Agent Pool of the Azure Container Registry type.

## Description
Creating an Agent Pool of the Azure Container Registry type with the given specs. ACR Task Agent Pool provides ACR Task (opens new window)execution in dedicated machine pools.<br>
Task Agent Pools provide a.o VNet Support: Agent Pools may be assigned to Azure VNets, providing access the resources in the VNet (eg, Container Registry, Key Vault, Storage).

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| acrName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing container registry. |
| acrAgentPoolName | string | <input type="checkbox"> | None | <pre>'private-pool'</pre> | The name of the agent pool |
| acrPoolSubnetId | string | <input type="checkbox"> | None | <pre>''</pre> | The resource id of the subnet the agent pool can be integrated in. |
| agentPoolMachineCount | int | <input type="checkbox"> | None | <pre>1</pre> | The number of virtual machines of the agent pool. |
| agentPoolOsType | string | <input type="checkbox"> | `'Linux'` or `'Windows'` | <pre>'Linux'</pre> | The type of OS for the agent machine |
| agentPoolTier | string | <input type="checkbox"> | None | <pre>'S1'</pre> | The tier of the agent machines of the agent pool. |

## Examples
<pre>
module agentpool 'br:contosoregistry.azurecr.io/containerregistry/registries/agentpools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'acragentpool')
  scope: resourceGroup(acrResourceGroupName)
  params: {
    acrName: 'myacr145'
    location: location
  }
}
</pre>
<p>Creates an agentpool of the containerregistry type</p>

## Links
- [Bicep Microsoft.ContainerRegistry registries agentpools](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries/agentpools?pivots=deployment-language-bicep)
