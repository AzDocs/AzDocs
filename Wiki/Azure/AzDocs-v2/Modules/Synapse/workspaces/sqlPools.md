# sqlPools

Target Scope: resourceGroup

## Synopsis
Create a Synapse Workspace sql pool.

## Description
Create a Synapse Workspace sql pool with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| sqlpoolName | string | <input type="checkbox" checked> | Length between 1-60 | <pre></pre> | Name of the Synapse SQL Pool. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| synapseWorkSpaceName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. Name of the existing Synapse Workspace. |
| collation | string | <input type="checkbox"> | None | <pre>'SQL_Latin1_General_CP1_CI_AS'</pre> | Specifies the collation of the Synapse SQL Pool. |
| sqlPoolsSkuName | string | <input type="checkbox"> | None | <pre>'DW100c'</pre> | Specifies the SKU of the Synapse SQL Pool. |
| sqlPoolsCreateMode | string | <input type="checkbox"> | `'Default'` or `'PointInTimeRestore'` or `'Recovery'` or `'Restore'` | <pre>'Default'</pre> | Specifies the mode of sql pool creation. For details see [link](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/sqlpools?pivots=deployment-language-bicep#sqlpoolresourceproperties) |

## Examples
<pre>
module synapsesqlpool 'br:contosoregistry.azurecr.io/synapse/workspaces/sqlpools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapsesqlpls')
  params: {
    synapseWorkSpaceName: 'synapsews'
    sqlpoolName: 'synsqlpool2'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace Sql Pool.</p>

## Links
- [Bicep Microsoft.Synapse workspaces sql pools](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/sqlpools?pivots=deployment-language-bicep)
