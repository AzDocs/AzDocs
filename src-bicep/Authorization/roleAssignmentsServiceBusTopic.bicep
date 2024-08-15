/*
.SYNOPSIS
Assign a role on the servicebus topic scope to a identity
.DESCRIPTION
Assign a role on the servicebus topic scope to a identity with the given specs.
.EXAMPLE
<pre>
module roleAssignmentsServiceBusTopic 'resource.roleAssignmentsServiceBusTopic.bicep' = {
  name: '${take(deployment().name, 41)}-roleAssignmentsTopic'
  params: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    serviceBusNamespaceName: serviceBusNamespaceName
    topicName: topicName
    principalType: principalType
  }
}
</pre>
<p>Assign a role on the servicebus topic scope to a identity</p>
.LINKS
- [Bicep Microsoft.Authorization/roleAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?pivots=deployment-language-bicep)
*/

@description('The type of principal you want to assign the role to.')
type principalTypes = 'User'
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
param principalType principalTypes = 'ServicePrincipal'

@description('The name of the Service bus namespace to assign the permissions on. This Service bus namespace should already exist.')
@minLength(6)
@maxLength(50)
param serviceBusNamespaceName string

@description('The name of the topic to assign the permissions on. This topic should already exist.')
@minLength(1)
@maxLength(260)
param topicName string

@description('The roledefinition ID you want to assign.')
@minLength(36)
@maxLength(36)
param roleDefinitionId string


resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespaceName
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: topicName
  parent: serviceBusNamespace
}

@description('Fetch the role based on the given roleDefinitionId. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: resourceGroup()
  name: roleDefinitionId
}

@description('Upsert the role with the given parameters')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(topic.id, principalId, roleDefinitionId)
  scope: topic
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinition.id
    principalType: principalType
  }
}
