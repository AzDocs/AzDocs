/*
.SYNOPSIS
Assigning a principal to a Kusto cluster with a specific role.
.DESCRIPTION
This module is used for assigning a principal to a Kusto cluster with a specific role.
.EXAMPLE
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
<p> This example assigns a user principal with the email '</p>
.EXAMPLE
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
.LINKS
- [Bicep Microsoft.Kusto clusters/principalAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters/principalassignments?pivots=deployment-language-bicep)
*/


@description('The name of the Kusto cluster to which the principal will be assigned.')
param clusterName string

@description('The name of the principal assignment. For example the principal name with role.')
param principalAssignmentsName string 

@description('The principal ID assigned to the cluster principal. It can be a user email, application ID, or security group name.')
param principalId string

type PrincipalType = 'App' | 'Group' | 'User'
param principalType PrincipalType

type RoleType = 'AllDatabasesAdmin' | 'AllDatabasesMonitor' | 'AllDatabasesViewer'
@description('Cluster principal role.')
param role RoleType

@description('The tenant ID of the principal. If not provided, the tenant ID of the current subscription will be used.')
param tenantId string?

resource cluster 'Microsoft.Kusto/clusters@2024-04-13' existing = {
  name: clusterName
}

resource principalAssignment 'Microsoft.Kusto/clusters/principalAssignments@2024-04-13' = {
  parent: cluster 
  name: principalAssignmentsName
  properties: { 
    principalId: principalId
    principalType: principalType
    role: role
    tenantId: empty(tenantId) ? null : tenantId
  }
}

output principalAssignmentId string = principalAssignment.id
