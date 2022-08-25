@description('The location for this Application Insights instance to be upserted in.')
param location string = resourceGroup().location

@description('The name of the scheduled query rules resource.')
@minLength(1)
@maxLength(260)
param scheduledQueryRuleName string

@description('List of Action group resource id\'s to notify users about the alert. An action group is a collection of notification preferences.')
param actionGroups array = []

@description('The description of the scheduled query rule.')
param scheduledQueryRuleDescription string = scheduledQueryRuleName

@description('Severity of the alert. Should be an integer between [0-4]. Value of 0 is severest. Relevant and required only for rules of the kind LogAlert.')
@minValue(0)
@maxValue(4)
param scheduledQueryRuleSeverity int = 3

@description('''
How often the scheduled query rule is evaluated represented in ISO 8601 duration format. Relevant and required only for rules of the kind LogAlert.
The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).
Defaults to PT5M.
''')
param evaluationFrequency string = 'PT5M'

@description('''
The period of time (in ISO 8601 duration format) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.
The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).
Defaults to PT5M.
''')
param windowSize string = 'PT5M'

@description('''
The criteria to alert. For options & formatting please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria.
Example:
[
  {
    failingPeriods: {
      minFailingPeriodsToAlert: 1
      numberOfEvaluationPeriods: 1
    }
    operator: 'GreaterThan'
    query: '<input query here>'
    threshold: 0
    resourceIdColumn: ''
    timeAggregation: 'Count'
    dimensions: []
  }
]
''')
param criteria array = []

@description('The list of resource id\'s that this scheduled query rule is scoped to.') // TODO: Explain a bit more?
param scopes array = []

@description('''
List of resource type of the target resource(s) on which the alert is created/updated. For example if the scope is a resource group and targetResourceTypes is Microsoft.Compute/virtualMachines, then a different alert will be fired for each virtual machine in the resource group which meet the alert criteria. Relevant only for rules of the kind LogAlert.
''')
param targetResourceTypes array = []

@description('The flag that indicates whether the alert should be automatically resolved or not. The default is true. Relevant only for rules of the kind LogAlert.')
param autoMitigate bool = true

@description('''
Mute actions for the chosen period of time (in ISO 8601 duration format) after the alert is fired. Relevant only for rules of the kind LogAlert.
The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).
Defaults to an empty string.
''')
param muteActionsDuration string = ''

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('Upsert the scheduledQueryRules resource with the given parameters.')
resource scheduledQueryRule 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  name: scheduledQueryRuleName
  location: location
  tags: tags
  properties: {
    actions: {
      actionGroups: actionGroups
      customProperties: {}
    }
    autoMitigate: autoMitigate
    muteActionsDuration: empty(muteActionsDuration) ? null : muteActionsDuration
    checkWorkspaceAlertsStorageConfigured: false
    #disable-next-line BCP036
    criteria: criteria
    description: scheduledQueryRuleDescription
    displayName: scheduledQueryRuleName
    enabled: true
    evaluationFrequency: evaluationFrequency
    scopes: scopes
    severity: scheduledQueryRuleSeverity
    targetResourceTypes: targetResourceTypes
    windowSize: windowSize
  }
}

@description('Output the resource name of the upserted scheduledQueryRule.')
output scheduledQueryRuleName string = scheduledQueryRule.name
@description('Output the resource ID of the upserted scheduledQueryRule.')
output scheduledQueryRuleResourceId string = scheduledQueryRule.id
