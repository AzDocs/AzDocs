# integrationRuntimes

Target Scope: resourceGroup

## Synopsis
Create a Synapse Workspace integration runtime.

## Description
Create a Synapse Workspace integration runtime with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| workspaceName | string | <input type="checkbox" checked> | None | <pre></pre> | Conditional. The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment. |
| integrationRuntimeName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the Integration Runtime. |
| type | string | <input type="checkbox" checked> | `'Managed'` or `'SelfHosted'` | <pre></pre> | Required. The type of Integration Runtime. |
| typeProperties | object | <input type="checkbox"> | None | <pre>{}</pre> | Conditional. Integration Runtime type properties. Required if type is "Managed". |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| resourceGroupName | string | The name of the Resource Group the Integration Runtime was created in. |
| integrationRuntimeName | string | The name of the Integration Runtime. |
| integrationRuntimeResourceId | string | The resource ID of the Integration Runtime. |

## Examples
<pre>
module synapseir 'br:contosoregistry.azurecr.io/synapse/workspaces/integrationruntimes:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapseir')
  params: {
    synapseWorkSpaceName: 'synapsews'
    integrationRuntimeName: 'synapseir'
    type: 'Managed'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace integration runtime.</p>

## Links
- [Bicep Microsoft.Synapse workspaces integration runtime](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/integrationruntimes?pivots=deployment-language-bicep)
