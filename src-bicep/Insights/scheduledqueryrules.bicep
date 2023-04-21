/*
.SYNOPSIS
Creating scheduled rules in Azure Monitor.
.DESCRIPTION
Creating scheduled rules in Azure Monitor..
.EXAMPLE
<pre>
module scheduledqueryalertrule 'br:contosoregistry.azurecr.io/insights/scheduledqueryrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 49), 'schedqryalrule')
  params: {
    location: location
    scheduledQueryRuleName: scheduledQueryRuleName
    actionGroups: [
      actionGroup.outputs.actionGroupResourceId
    ]
    scheduledQueryRuleDescription: scheduledQueryRulesDescription
    criteria: {
      allOf: [
        {
          query: scheduledQueryRulesQuery
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 0
          failingPeriods: {
            numberOfEvaluationPeriods: 1
            minFailingPeriodsToAlert: 1
          }
        }
      ]
    }
    targetResourceTypes: [
      'microsoft.insights/components'
    ]
    scopes: [
      appInsights.outputs.appInsightsResourceId
    ]
  }
}
</pre>
<p>Creates a schedules rules resource in azure monitor with the name 'scheduledQueryRuleName'</p>
.LINKS
- [Bicep Scheduled Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
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
How often the metric alert is evaluated represented in ISO 8601 duration format.
Examples:
PT5M is 5 minutes
PT15M is 15 minutes
PT30M is 30 minutes
PT1H is 1 hour
''')
param evaluationFrequency string = 'PT5M'

@description('''
The period of time (in [ISO 8601 duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations)) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.
The format for this string is P<days>DT<hours>H<minutes>M<seconds>S. You always need to mention de T if something the time is needed.
for example:
P2D is 2 days
P5DT5M is 5 days and 5 minutes
PT5M is 5 minutes
PT1H is 1 hour
''')
param windowSize string = 'PT5M'

@description('''
The criteria to alert.  The AllOf: [] is required and it cannot be empty.
For options & formatting please refer to [scheduledqueryrulecriteria](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria).
Example:
{
  allOf: [
    {
      query: 'traces | where operation_Name == "FlowRunLastJob"'
      timeAggregation: 'Count'
      dimensions: []
      operator: 'GreaterThan'
      threshold: 0
      failingPeriods: {
        numberOfEvaluationPeriods: 1
        minFailingPeriodsToAlert: 1
      }
    }
  ]
}
''')
param criteria object

@description('''The list of resource id\'s that this scheduled query rule is scoped to, for example the Application Insights Resource Id.
Scopes list should contain at least 1 resource Id.
Example:
[ appInsights.outputs.appInsightsResourceId ]
''')
param scopes array

@description('''
List of resource type of the target resource(s) on which the alert is created/updated. For example if the scope is a resource group and targetResourceTypes is Microsoft.Compute/virtualMachines, then a different alert will be fired for each virtual machine in the resource group which meet the alert criteria. Relevant only for rules of the kind LogAlert.
''')
param targetResourceTypes array = []

@description('The flag that indicates whether the alert should be automatically resolved or not. The default is true. Relevant only for rules of the kind LogAlert.')
param autoMitigate bool = true

@description('''
Mute actions for the chosen period of time (in ISO 8601 duration format) after the alert is fired. Relevant only for rules of the kind LogAlert.
Defaults to an empty string.
Examples: 
PT1M is 1 minute
PT5M is 5 minutes
PT30M is 30 minutes
PT1H is 1 hour
''')
param muteActionsDuration string = ''

@description('Specifies whether to check linked storage and fail creation if the storage was not found')
param checkWorkspaceAlertsStorageConfigured bool = false

@description('Specifies whether the alert is enabled')
param isEnabled bool = true

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
resource scheduledQueryRule 'Microsoft.Insights/scheduledQueryRules@2022-08-01-preview' = {
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
    checkWorkspaceAlertsStorageConfigured: checkWorkspaceAlertsStorageConfigured
    #disable-next-line BCP036
    criteria: criteria
    description: scheduledQueryRuleDescription
    displayName: scheduledQueryRuleName
    enabled: isEnabled
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
