# workspaces

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="customerManagedKeyType">customerManagedKeyType</a>  | <pre>{</pre> |  |  | 
| <a id="managedIdentitiesType">managedIdentitiesType</a>  | <pre>{</pre> |  |  | 
| <a id="IdentityType">IdentityType</a>  | <pre></pre> | type |  | 

## Synopsis
Create a Synapse Workspace

## Description
Create a Synapse Workspace with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | Length between 1-50 | <pre></pre> | Specifies the name of the Synapse Workspace. |
| managedResourceGroupName | string | <input type="checkbox"> | Length between 0-90 | <pre>''</pre> | Optional. Workspace managed resource group, when omitted it will be automatically named. The resource group name uniquely identifies the resource group within the user subscriptionId.<br>The resource group name must be no longer than 90 characters long, and must be alphanumeric characters (Char.IsLetterOrDigit()) and \'-\', \'_\', \'(\', \')\' and\'.\'. <br>Note that the name cannot end with \'.\'. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Location for the resource. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| azureADOnlyAuthentication | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable or Disable AzureADOnlyAuthentication on all Workspace sub-resources. |
| storageAccountName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing data lake (ADLS Gen2) storage account. <br>Your Azure Synapse Analytics workspace uses this storage account as the primary storage account and the container to store workspace data. <br>The storage account must be in the same region as the workspace. Users that need to work with the workspace data must have access to this storage account.<br>Owner and Storage Blob Data Owner roles are required on the storage account.<br>The Managed identity for your Azure Synapse Analytics workspace needs Storage Blob Data Contributor, it has the same name as the workspace. |
| defaultDataLakeStorageFilesystem | string | <input type="checkbox"> | None | <pre>'synapseblob'</pre> | The name of the default ADLS Gen2 file system for the data lake storage account. Required and can be any string. |
| managedVirtualNetwork | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Enable this to ensure that connections from your workspace to your data sources use Azure Private Links.<br>Creating a workspace with a Managed workspace Virtual Network associated with it ensures that your workspace is network isolated from other workspaces.<br>Data integration and Spark resources are deployed in it. Dedicated SQL pool and serverless SQL pool are multi-tenant capabilities and therefore reside outside of the Managed workspace Virtual Network. Intra-workspace communication to dedicated SQL pool and serverless SQL pool use Azure private links. <br>These private links are automatically created for you when you create a workspace with a Managed workspace Virtual Network associated to it.<br>You can create managed private endpoints to your data sources.<br>If this is set to false, make sure you add the necessary firewall rules for yourself to allow access to your Synapse workspace for the Dev Portal. |
| defaultDataLakeStorageCreateManagedPrivateEndpoint | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Create managed private endpoint to the default storage account or not. <br>If Yes is selected, a managed private endpoint connection request is sent to the workspace\'s primary Data Lake Storage Gen2 account to access data. <br>This must be approved by an owner of the storage account. |
| customerManagedKey | customerManagedKeyType? | <input type="checkbox" checked> | None | <pre></pre> | Optional. The customer managed key definition. |
| sqlAdministratorLogin | string | <input type="checkbox"> | None | <pre>'sqladminuser'</pre> | Required. Login for administrator access to the workspace\'s SQL pools. |
| sqlAdministratorLoginPassword | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Password for administrator access to the workspace\'s SQL pools. If you don\'t provide a password, one will be automatically generated. You can change the password later. |
| identity | IdentityType | <input type="checkbox"> | None | <pre>{<br>  type: 'SystemAssigned'<br>}</pre> | Managed service identity to use for this configuration store. Defaults to a system assigned managed identity. For object format, refer to [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep#managedserviceidentity). |
| allowedAadTenantIdsForLinking | array | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Allowed AAD Tenant IDs For Linking. |
| linkedAccessCheckOnTargetResource | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Linked Access Check On Target Resource. |
| preventDataExfiltration | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Prevent Data Exfiltration. |
| publicNetworkAccess | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Optional. Enable or Disable public network access to workspace.<br>When public network access is disabled, you can connect to your workspace only using private endpoints. Also any firewall rules that you might configure will not be applied.<br>And the publish button to the integrated Git repo will not work because the access to Live mode is blocked by the firewall settings.<br>When public network access is enabled, you can connect to your workspace also from public networks and use firewall rules. |
| purviewResourceID | string | <input type="checkbox"> | None | <pre>''</pre> | Optional. Purview Resource ID. |
| workspaceRepositoryConfiguration | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Git integration settings. |
| trustedServiceBypassEnabled | bool | <input type="checkbox"> | None | <pre>false</pre> | Optional. Enable or Disable trusted service bypass. |
| privateEndpointDevName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the private endpoint for the development endpoint. |
| privateEndpointSqlOdName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the private endpoint for the Sql OnDemand endpoint. |
| privateEndpointSqlName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the private endpoint for the Sql endpoint. |
| privateEndpointDevSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the subnet to deploy the private endpoint for the development endpoint to. |
| privateEndpointSqlOdSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the subnet to deploy the private endpoint for the Sql OnDemand endpoint to. |
| privateEndpointSqlSubnetName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the subnet to deploy the private endpoint for the Sql endpoint to. |
| privateEndpointVirtualNetworkResourceGroupName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the resource group where the virtual network resides in. |
| privateEndpointVirtualNetworkName | string | <input type="checkbox"> | None | <pre>''</pre> | The name of the virtual network to deploy the private endpoint for the endpoints to. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| synapseWorkSpaceName | string | The name of the deployed Synapse Workspace. |
| synapseWorkSpaceResourceId | string | The resource ID of the deployed Synapse Workspace. |
| developmentEndpoint | string | The development endpoint of the deployed Synapse Workspace. |
| webEndpoint | string | the web endpoint of the deployed Synapse Workspace. |
| connectivityEndpoints | object | The workspace connectivity endpoints. |
| systemAssignedManagedIdentityPrincipalId | string | The principal ID of the system assigned identity. |

## Examples
<pre>
module synapsews 'br:contosoregistry.azurecr.io/synapse/workspaces:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'synapsews')
  params: {
    synapseWorkSpaceName: 'synapsews'
    sqlAdministratorLogin: 'sqladminuser'
    storageAccountName: 'stgsynws1234'
    azureADOnlyAuthentication: false
    createDevEndpointPe: true
    privateEndpointDevSubnetName: 'privateendpointsubnet'
    privateEndpointVirtualNetworkResourceGroupName: 'sharedservices-rg'
    privateEndpointVirtualNetworkName: 'myvnetname'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace.</p>

## Links
- [Bicep Microsoft.Synapse workspaces](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces?pivots=deployment-language-bicep)
