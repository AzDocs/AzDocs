# principalAssignments

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="PrincipalType">PrincipalType</a>  | <pre>'App' &#124; 'Group' &#124; 'User'</pre> |  |  | 
| <a id="RoleType">RoleType</a>  | <pre>'AllDatabasesAdmin' &#124; 'AllDatabasesMonitor' &#124; 'AllDatabasesViewer'</pre> |  |  | 

## Synopsis
Assigning a principal to a Kusto cluster with a specific role.

## Description
This module is used for assigning a principal to a Kusto cluster with a specific role.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| clusterName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the Kusto cluster to which the principal will be assigned. |
| principalId | string | <input type="checkbox" checked> | None | <pre></pre> | The principal ID assigned to the cluster principal. It can be a user email, application ID, or security group name. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> |  |
| role | RoleType | <input type="checkbox" checked> | None | <pre></pre> | Cluster principal role. |
| tenantId | string? | <input type="checkbox" checked> | None | <pre></pre> | The tenant ID of the principal. If not provided, the tenant ID of the current subscription will be used. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| principalAssignmentId | string |  |

## Examples
<pre>
module principalAssignments 'br/azdocs:kusto/clusters/principalAssignments:latest' = {
  name: '${take(deployment().name, 61)}-pa'
  params:{
    clusterName: clusterName
    principalId: 'users@domain.com'
    principalType: 'User'
    role: 'AllDatabasesViewer'
  } 
}
</pre>
<p> This example assigns a user principal with the email '
<pre>

module principalAssignments 'br/azdocs:kusto/clusters/principalAssignments:latest' = {
  name: '${take(deployment().name, 61)}-pa'
  params:{
    clusterName: clusterName
    principalId: '8a294a5f-8976-48a5-9eb0-b69f5bffc7d2' //applicationId of the service principal
    principalType: 'App'
    role: 'AllDatabasesViewer'
  } 
}  
</pre>
<p> This example assigns a service principal with the application ID '8a294a5f-8976-48a5-9eb0-b69f5bffc7d2' to the Kusto cluster assignment with the 'AllDatabasesViewer' role.</p>

## Links
- [Bicep Microsoft.Kusto clusters/principalAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters/principalassignments?pivots=deployment-language-bicep)
