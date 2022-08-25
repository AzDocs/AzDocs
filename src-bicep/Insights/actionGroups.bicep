@description('The name of the actionGroup to upsert.')
@minLength(1)
@maxLength(260)
param actionGroupName string

@description('Short name up to 12 characters for the Action group')
@maxLength(12)
param groupShortName string

@description('Array of emailReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#emailreceiver for documentation.')
param emailReceivers array = []
@description('Array of webhookReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#webhookreceiver for documentation.')
param webhookReceivers array = []
@description('Array of voiceReceivers to receive alerts for this alertGroup using Voicecalls. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#voicereceiver for documentation.')
param voiceReceivers array = []
@description('Array of smsReceivers to receive alerts for this alertGroup using SMS. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#smsreceiver for documentation.')
param smsReceivers array = []
@description('Array of logicAppReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#logicappreceiver for documentation.')
param logicAppReceivers array = []
@description('Array of itsmReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#itsmreceiver for documentation.')
param itsmReceivers array = []
@description('Array of azureFunctionReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#azurefunctionreceiver for documentation.')
param azureFunctionReceivers array = []
@description('Array of azureAppPushReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#azureapppushreceiver for documentation.')
param azureAppPushReceivers array = []
@description('Array of automationRunbookReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#automationrunbookreceiver for documentation.')
param automationRunbookReceivers array = []
@description('Array of armRoleReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#armrolereceiver for documentation.')
param armRoleReceivers array = []
@description('Array of eventHubReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#eventhubreceiver for documentation.')
param eventHubReceivers array = []

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the actionGroup with the given parameters.')
resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  tags: tags
  location: 'global'
  properties: {
    groupShortName: groupShortName
    enabled: true
    emailReceivers: emailReceivers
    eventHubReceivers: eventHubReceivers
    webhookReceivers: webhookReceivers
    smsReceivers: smsReceivers
    logicAppReceivers: logicAppReceivers
    itsmReceivers: itsmReceivers
    voiceReceivers: voiceReceivers
    azureFunctionReceivers: azureFunctionReceivers
    azureAppPushReceivers: azureAppPushReceivers
    automationRunbookReceivers: automationRunbookReceivers
    armRoleReceivers: armRoleReceivers
  }
}

@description('The Resource ID of the upserted action group')
output actionGroupResourceId string = actionGroup.id
@description('The name of the upserted action group')
output actionGroupName string = actionGroup.name
