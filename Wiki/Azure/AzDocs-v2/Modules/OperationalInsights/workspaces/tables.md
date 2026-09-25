# tables

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="columnType">columnType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;name: string<br>&nbsp;&nbsp;&nbsp;displayName: string?<br>&nbsp;&nbsp;&nbsp;description: string?<br>&nbsp;&nbsp;&nbsp;type: 'boolean' &#124; 'datetime' &#124; 'dynamic' &#124; 'guid' &#124; 'int' &#124; 'long' &#124; 'real' &#124; 'string'<br>&nbsp;&nbsp;&nbsp;dataTypeHint: 'armPath' &#124; 'guid' &#124; 'ip' &#124; 'uri' &#124; null<br>}</pre> |  |  | 

## Synopsis
Creating a custom table in an existing Log Analytics Workspace.

## Description
Creating a custom table in an existing Log Analytics Workspace.
<pre>
module tableinlaw 'br:contosoregistry.azurecr.io/operationalinsights/workspaces/tables.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 57), 'tables')
  params: {
    logAnalyticsWorkspaceName: 'myworkspacename'
    tableName: 'mytable'
    additionalColumns: [
      {
        name: 'SubscriptionName'
        type: 'string'
      }
      {
        name: 'ResourceGroupName'
        type: 'string'
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Contributor'
        principalId: 'e1691248-3964-4677-ad3c-31e67e3e190f'
      }
    ]
  }
}
</pre><br>
<p>Creates a table mytable_CL in an existing Log Analytics Workspace with the name myworkspacename.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| tableName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the table. |
| schemaDisplayName | string | <input type="checkbox"> | None | <pre>'Schema for &#36;{tableName} table'</pre> | The displayname of the schema. |
| schemaDescription | string | <input type="checkbox"> | None | <pre>'Schema for &#36;{tableName} table'</pre> | The description of the schema. |
| additionalColumns | [columnType](#columnType)[] | <input type="checkbox"> | None | <pre>[]</pre> | Additional columns to add to the table. |
| logAnalyticsWorkspaceName | string | <input type="checkbox" checked> | None | <pre></pre> | Conditional. The name of the (existing) parent workspaces. Required if the template is used in a standalone deployment. |
| plan | string | <input type="checkbox"> | `'Basic'` or `'Analytics'` | <pre>'Analytics'</pre> | Optional. Instruct the system how to handle and charge the logs ingested to this table. |
| restoredLogs | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Restore parameters. |
| retentionInDays | int | <input type="checkbox"> | Value between -1-730 | <pre>-1</pre> | Optional. The table retention in days, between 4 and 730. Setting this property to -1 will default to the workspace retention. |
| searchResults | object | <input type="checkbox"> | None | <pre>{}</pre> | Optional. Parameters of the search job that initiated this table. |
| totalRetentionInDays | int | <input type="checkbox"> | Value between -1-2555 | <pre>-1</pre> | Optional. The table total retention in days, between 4 and 2555. Setting this property to -1 will default to table retention. |
| roleAssignments | roleAssignment[] | <input type="checkbox"> | None | <pre>[]</pre> | Optional. Array of role assignments to create on the table. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| name | string | The name of the table. |
| resourceId | string | The resource ID of the table. |

## Links
- [Bicep Microsoft.OperationalInsights workspaces tables](https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces/tables?pivots=deployment-language-bicep)
