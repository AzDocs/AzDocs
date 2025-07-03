/*
.SYNOPSIS
  Creating an Action Rule.
.DESCRIPTION
  Creating an Action Rule for Azure Monitor Alerts Management.
<pre>
module actionRule 'br:contosoregistry.azurecr.io/insights/actionrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'actionrule')
  params: {
    actionRuleName: 'apr-appl-dev'
    actionRuleDescription: 'Suppress alerts for dev environment'
    scopes: [subscription().id]
    actions: [
      {
        actionType: 'RemoveAllActionGroups'
      }
    ]
    conditions: [
      {
        field: 'severity'
        operator: 'Equals'
        values: [
          'Sev0'
          'Sev1'
        ]
      }
    ]
    schedule: {
      effectiveFrom: '2025-06-01T00:00:00'
      effectiveUntil: '2025-12-31T23:59:59'
      timeZone: 'UTC'
      recurrences: [
        {
          recurrenceType: 'Weekly'
          daysOfWeek: ['Monday', 'Wednesday']
          startTime: '09:00:00'
          endTime: '17:00:00'
        }
      ]
    }
  }
}
</pre>
<p>Example configures a suppression action rule for Sev3/Sev4 alerts in the dev environment.</p>
.LINKS
- [Bicep Action Rules Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep)
*/
@description('The name for this action rule resource, required.')
@minLength(1)
@maxLength(260)
param actionRuleName string

@description('Allows you to override the description for this action rule.')
param actionRuleDescription string = actionRuleName

@description('''
The scope this action rule will apply to. This defaults to the whole subscription, but you can pass an array of resourceId\'s to apply to. 
See https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep
Scopes are the resources that the alert processing rule will apply to. The rule will only apply to alerts that are generated from these resources.
Scopes are specified as resource IDs. For example, the scope for a virtual machine would be: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}`.
''')
param scopes array = [subscription().id]

@description('''Conditions on which alerts will be filtered.
Example:
`conditions: [
  {
    field: 'Severity'
    operator: 'Equals'
    values: [
      'Sev2'
      'Sev3'
      'Sev1'
    ]
  }
]`
In this example the severity of the alert is checked against the values `Sev1`, `Sev2`, and `Sev3`. 
If the severity of the alert matches any of these values, the alert will be processed according to the actions specified in the action rule.
If the severity of the alert does not match any of these values, the alert will be ignored and no actions will be taken.
''')
param conditions Condition[]?

type Condition = {
  field: string
  operator: string
  values: string[]
}

@description('''
Action type for alert processing rule. Use actionType: RemoveAllActionGroups or actionType: AddActionGroups with actionGroupIds.
Example:
`actions: [
  {
    actionGroupIds: [
      '/subscriptions/subscriptionId/resourceGroups/resourceGroupId/providers/microsoft.insights/actionGroups/actionGroupName'
    ]
    actionType: 'AddActionGroups'
  }
]`
Actions are the operations that will be performed when the alert processing rule is triggered. The actions can include sending notifications, executing webhooks, or triggering other workflows.
Actions are specified as an array of objects, where each object represents a specific action to be taken.
The action type can be one of the following:
- `AddActionGroups`: Adds action groups to the alert processing rule.
  - actionGroupIds: An array of action group IDs to be added to the alert processing rule.
- `RemoveAllActionGroups`: Removes all action groups from the alert processing rule.
''')
param actions array = [
  {
    actionType: 'RemoveAllActionGroups'
  }
]

@description('''
Defines the schedule for the alert processing rule.
The schedule specifies when the alert processing rule will be active. It includes the start and end times, the time zone, and recurrence details. 
Recurrences can be configured to apply on specific days of the week.
Example:
schedule: {
  effectiveFrom: '2025-04-04T00:00:00'
  effectiveUntil: '2025-04-05T00:00:00'
  timeZone: 'UTC'
  recurrences: [
    {
      daysOfWeek: [
        'Monday'
        'Tuesday'
        'Wednesday'
        'Thursday'
        'Friday'
      ]
      recurrenceType: 'Weekly'
    }
  ]
}
In this example:
- The rule is active from April 4, 2025, to April 5, 2025.
- The time zone is set to UTC.
- The rule recurs weekly on weekdays (Monday to Friday).
''')
param schedule Schedule?

type Schedule = {
  effectiveFrom: string?
  effectiveUntil: string?
  timeZone: string
  recurrences: {
    recurrenceType: 'Weekly' | 'Daily' | 'Monthly'
    daysOfWeek: string[]?
    startTime: string
    endTime: string
  }[]
}

@description('Optional. Indicates if the given action rule is enabled or disabled.')
param enabled bool = true

@description('Optional. Resource tags.')
param tags object?

@description('Upsert the actionRule resource')
resource actionRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: actionRuleName
  tags: tags
  location: 'Global'
  properties: {
    description: actionRuleDescription
    scopes: scopes
    actions: actions
    enabled: enabled
    conditions: conditions
    schedule: schedule
  }
}

@description('The resource ID of the Alert Processing Rule.')
output actionRuleResourceId string = actionRule.id

@description('The name of the Alert Processing Rule.')
output actionRuleResourceName string = actionRule.name
