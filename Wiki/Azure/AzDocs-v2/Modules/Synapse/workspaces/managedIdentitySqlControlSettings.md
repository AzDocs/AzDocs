# managedIdentitySqlControlSettings

Target Scope: resourceGroup

## Synopsis
Create a Synapse workspaces managed identity sqlcontrolsettings.

## Description
Create a Synapse workspaces managed identity sqlcontrolsettings with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the existing Synapse Workspace. |
| desiredStateGrantSqlControlToManagedIdentity | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | Specifies the desired state of the managed identity sql control settings. Determine to grant sql control to managed identity. |

## Examples
<pre>
module synapsemanidsqlctl 'br:contosoregistry.azurecr.io/synapse/workspaces/managedidentitysqlcontrolsettings:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'synapsemaidsqlctl')
  params: {
    synapseWorkSpaceName: 'synapsews'
    desiredStateGrantSqlControlToManagedIdentity: 'Enabled'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace Sql Pool.</p>

## Links
- [Bicep Microsoft.Synapse workspaces managed identity sqlcontrolsettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/managedidentitysqlcontrolsettings?pivots=deployment-language-bicep)
