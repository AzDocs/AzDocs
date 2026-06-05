import { PrincipalType } from '../Common/authorizationTypes.bicep'
/*
.SYNOPSIS
Assign a role on the servicebus queue scope to a identity
.DESCRIPTION
Assign a role on the servicebus queue scope to a identity with the given specs.
.EXAMPLE
<pre>
module roleAssignmentsServiceBusQueue 'resource.roleAssignmentsServiceBusQueue.bicep' = {
  name: '${take(deployment().name, 41)}-roleAssignmentsQueue'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    serviceBusNamespaceName: serviceBusNamespaceName
    queueName: queueName
    principalType: principalType
  }
}
</pre>
<p>Assign a role on the servicebus queue scope to a identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

@description('The type of principal you want to assign the role to.')
type principalTypes =
  | 'User'
  | 'Group'
  | 'ServicePrincipal'
  | 'Unknown'
  | 'DirectoryRoleTemplate'
  | 'ForeignGroup'
  | 'Application'
  | 'MSI'
  | 'DirectoryObjectOrGroup'
  | 'Everyone'

@description('The AAD Object ID of the pricipal you want to assign the role to.')
@minLength(36)
@maxLength(36)
param principalId string

@description('The type of principal you want to assign the role to.')
param principalType PrincipalType

@description('The name of the Service bus namespace to assign the permissions on. This Service bus namespace should already exist.')
@minLength(6)
@maxLength(50)
param serviceBusNamespaceName string

@description('The name of the queue to assign the permissions on. This queue should already exist.')
@minLength(1)
@maxLength(260)
param queueName string

@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' existing = {
  name: queueName
  parent: serviceBusNamespace
}

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(queue.id, principalId, roleDefinitionId)
  scope: queue
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
