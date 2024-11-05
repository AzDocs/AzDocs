# administrators

Target Scope: resourceGroup

## Synopsis
Create a Synapse Workspace administrators.

## Description
Create a Synapse Workspace administrators and assign an identity (e.g a managed identity) as admin of synapse workspacewith the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | Length between 5-50 | <pre></pre> | Required. Name of the existing Synapse Workspace. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| userAssignedManagedIdentityName | string | <input type="checkbox"> | None | <pre>replace(resourceGroup().name, 'rg', 'mi')</pre> | The name to assign to this user assigned managed identity. |
| sidObjectId | string | <input type="checkbox"> | None | <pre>''</pre> | Required. Object ID of the workspace active directory administrator. This can be a EntraId Group or User Object ID. |

## Examples
<pre>
module synapseadmins 'br:contosoregistry.azurecr.io/synapse/workspaces/administrators:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapseadmins')
  params: {
    synapseWorkSpaceName: 'synapsews'
    userAssignedManagedIdentityName: replace(resourceGroup().name, 'rg', 'mi') //will be the admin of the synapse workspace and the UIM will be created
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace administrators.</p>

## Links
- [Bicep Microsoft.Synapse workspaces administrators](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/administrators?pivots=deployment-language-bicep)
