@description('The location of this logic app to reside in. This defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('The resource name of the logic app')
@minLength(1)
@maxLength(43)
param logicAppName string

@description('The identity object for this logic app. This defaults to a System Assigned Managed Identity. For formatting, please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.logic/workflows?pivots=deployment-language-bicep#managedserviceidentity.')
param logicAppIdentity object = {
  type: 'SystemAssigned'
}

@description('''
The definition for this logic app. For options & formatting, please refer to https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-workflow-definition-language.
Example:
  {
    '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
    actions: []
    contentVersion: '1.0.0.0'
    outputs: []
    parameters: []
    triggers: []
  }
''')
param definition object = {}

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the Logic App with the given parameters.')
resource consumptionLogicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: logicAppName
  tags: tags
  location: location
  identity: logicAppIdentity
  properties: {
    definition: definition
    parameters: {}
  }
}

@description('Output the principal ID for the identity running this logic app.')
output principalId string = consumptionLogicApp.identity.principalId
@description('Output the logic app\'s resource name.')
output logicAppName string = consumptionLogicApp.name
