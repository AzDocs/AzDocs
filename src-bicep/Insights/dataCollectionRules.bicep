/*
.SYNOPSIS
Creating a data collection rule.
.DESCRIPTION
Creating a data collection rule (DCR). Data collection rules (DCRs) are sets of instructions that determine how to collect and process telemetry sent to Azure Monitor.
.NOTE
By default, the Microsoft.Insights resource provider isnt registered in a Subscription. Ensure to register it successfully before trying to create a Data Collection Rule.
.EXAMPLE
<pre>
module dcrule 'br:contosoregistry.azurecr.io/insights/datacollectionrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'dcr')
  params: {
    dataCollectionRuleName: 'dcrname'
    dataCollectionEndpoint: '/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourceGroups/azure-azdovmss-dev/providers/Microsoft.Insights/dataCollectionEndpoints/dceprivateendpointchk'
    dataSources: {}
    kind: 'Direct'
    dataFlows: [
      {
        streams: [
          'Custom-MyTable_CL'
        ]
        destinations: [
          guid('/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev')
        ]
        outputStream: 'Custom-MyTable_CL'
        transformKql: 'source'
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: '/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev'
          name: guid('/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev')
        }
      ]
    }
  }
}
</pre>
<p>Creates a data collection rule in Azure Monitor where the data is sent to a custom table in Log Analytics workspace.</p>
.LINKS
- [Bicep Data Collection rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Required. The name of the data collection rule. The name is case insensitive.')
param dataCollectionRuleName string

@description('A Data Collection Endpoint is optional for collecting Windows Event Logs, Linux Syslog or Performance Counters. It is required for all other data sources.')
param dataCollectionEndpointId string?

@description('Required. The specification of data flows.')
param dataFlows array

@description('Specification of data sources that will be collected. Can be empty if the parameter kind is not Linux or Windows.')
param dataSources object

@description('Optional. Description of the data collection rule.')
param dataCollectionRuleDescription string?

@description('Required. Specification of destinations that can be used in data flows.')
param destinations object

@description('The kind of the resource. In the Portal this is represented as Platform Type. Additional undocumented but supported values are: Direct, WorkspaceTransforms,AgentDirectToStore, AgentSettings, PlatformTelemetry.')
@allowed([
  'Linux'
  'Windows'
  'Direct'
  'WorkspaceTransforms'
  'AgentDirectToStore'
  'AgentSettings'
  'PlatformTelemetry'
])
param kind string = 'Linux'

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Declaration of custom streams used in this rule.')
param streamDeclarations object?

@description('Optional. Resource tags.')
param tags object?

type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

var builtInRoleNames = {
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator (Preview)': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
  )
  'User Access Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
  )
  'Monitoring Metrics Publisher': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '3913510d-42f4-4e42-8a64-420c390055eb'
  )
}


// ===================================== Resources =====================================
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  kind: kind
  location: location
  name: dataCollectionRuleName
  tags: tags
  properties: {
    dataSources: dataSources
    destinations: destinations
    dataFlows: dataFlows
    dataCollectionEndpointId: dataCollectionEndpointId
    streamDeclarations: streamDeclarations
    description: dataCollectionRuleDescription
  }
}

resource dataCollectionRule_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(dataCollectionRule.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: dataCollectionRule
  }
]


@description('The name of the dataCollectionRule.')
output name string = dataCollectionRule.name

@description('The resource ID of the dataCollectionRule.')
output resourceId string = dataCollectionRule.id

@description('The name of the resource group the dataCollectionRule was created in.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = dataCollectionRule.location
