/*
.SYNOPSIS
Creating a Alert Processing Rule. 
.DESCRIPTION
Creating a Alert Processing Alert Rule, used for management of alert rules.
<pre>
module smartrules 'br:contosoregistry.azurecr.io/alertsmanagement/actionrule:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 54), 'actionrule')
  params: {
    actions: actions
    actionRuleDescription: 'My alert processing rule'
    actionRuleName: 'apr-myrule-tst'
    conditions: !empty(conditions) ? conditions : null
    isEnabled: isEnabled
    schedule: schedule
    scopes: scopes
    tags: tags
  }
}
</pre>
<p>Creates an alert processing rule with the name 'apr-myrule-tst' and displayname 'My alert processing rule'.</p>
.LINKS
- [Bicep Action Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep#recurrence)
*/
// ===================================== Parameters =====================================
@description('''Actions to be applied.

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
param actions array

@description('Description of alert processing rule.')
@minLength(1)
param actionRuleDescription string

@description('The name of the action rule.')
@minLength(1)
param actionRuleName string

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

In this example the severity of the alert is checked against the values `Sev1`, `Sev2`, and `Sev3`. If the severity of the alert matches any of these values, the alert will be processed according to the actions specified in the action rule.
If the severity of the alert does not match any of these values, the alert will be ignored and no actions will be taken.
''')
param conditions array?

@description('Indicates if the given alert processing rule is enabled or disabled.')
param isEnabled bool = true

@description('''Scopes on which alert processing rule will apply.

Scopes are the resources that the alert processing rule will apply to. The rule will only apply to alerts that are generated from these resources.
Scopes are specified as resource IDs. For example, the scope for a virtual machine would be: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}`.
''')
param scopes string[]

@description('''Defines the schedule for the alert processing rule.

The schedule specifies when the alert processing rule will be active. It includes the start and end times, the time zone, and recurrence details. Recurrences can be configured to apply on specific days of the week.

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
param schedule object?

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

// ===================================== Resources =====================================
resource alertRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = {
  name: actionRuleName
  location: 'Global'
  tags: tags
  properties: {
    scopes: scopes
    conditions: conditions
    enabled: isEnabled
    actions: actions
    description: actionRuleDescription
    schedule: schedule
  }
}

// ===================================== Outputs =====================================
@description('The resource ID of the action rule.')
output actionRuleId string = alertRule.id
@description('The name of the action rule.')
output actionRuleName string = alertRule.name
