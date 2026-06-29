# roleAssignmentsKustoCluster

Target Scope: resourceGroup

## Synopsis
Configuring role assignment for a Kusto cluster.

## Description
This module is used for creating role assignments for an existing Azure Data Explorer (Kusto) cluster.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| roleDefinitionId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The roledefinition ID you want to assign. |
| principalId | string | <input type="checkbox" checked> | Length is 36 | <pre></pre> | The AAD Object ID of the principal you want to assign the role to. |
| principalType | PrincipalType | <input type="checkbox" checked> | None | <pre></pre> | The type of principal you want to assign the role to. |
| kustoClusterName | string | <input type="checkbox" checked> | Length between 4-22 | <pre></pre> | The name of the Kusto cluster to assign the permissions on. This Kusto cluster should already exist. |

## Examples
<pre>
module roleKustoCluster 'br:contosoregistry.azurecr.io/authorization/roleassignmentskustocluster:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 47), 'roleskusto')
  params: {
    principalType: 'ServicePrincipal'
    principalId: 'a348f815-0d14-4a85-b2fe-d3b36519e4fd' //object id of the service principal
    roleDefinitionId: '4d97b98b-1d4f-4787-a291-c67834d212e7' //Azure Data Explorer Contributor
    kustoClusterName: myKustoCluster.outputs.clusterName
  }
}
</pre>
<p>Assign a role on the Kusto cluster scope to an identity.</p>

## Links
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)<br>
- [Bicep Microsoft.Kusto/clusters](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters?pivots=deployment-language-bicep)
