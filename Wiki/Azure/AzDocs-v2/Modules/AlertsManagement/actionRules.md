# actionRules

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="Condition">Condition</a>  | <pre>{</pre> |  |  | 
| <a id="ActionType">ActionType</a>  | <pre>ActionTypeRemoveAllActionGroups &#124; ActionTypeAddActionGroups</pre> | actionType |  | 
| <a id="ActionTypeRemoveAllActionGroups">ActionTypeRemoveAllActionGroups</a>  | <pre>{</pre> |  |  | 
| <a id="ActionTypeAddActionGroups">ActionTypeAddActionGroups</a>  | <pre>{</pre> |  |  | 
| <a id="Schedule">Schedule</a>  | <pre>{</pre> |  |  | 
| <a id="Recurrence">Recurrence</a>  | <pre>DailyRecurrence &#124; monthlyRecurrence &#124; WeeklyRecurrence </pre> | recurrenceType |  | 
| <a id="DailyRecurrence">DailyRecurrence</a>  | <pre>{</pre> |  |  | 
| <a id="monthlyRecurrence">monthlyRecurrence</a>  | <pre>{</pre> |  |  | 
| <a id="WeeklyRecurrence">WeeklyRecurrence</a>  | <pre>{</pre> |  |  | 
| <a id="DayOfTheWeek">DayOfTheWeek</a>  | <pre>'Monday' &#124; 'Tuesday' &#124; 'Wednesday' &#124; 'Thursday' &#124; 'Friday' &#124; 'Saturday' &#124; 'Sunday'</pre> |  |  | 

## Synopsis
  Creating an Action Rule.

## Description
  Creating an Action Rule for Azure Monitor Alerts Management.<br>
<pre><br>
module actionRule 'br:contosoregistry.azurecr.io/insights/actionrules:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 53), 'actionrule')<br>
  params: {<br>
    actionRuleName: 'apr-appl-dev'<br>
    actionRuleDescription: 'Suppress alerts for dev environment'<br>
    scopes: [subscription().id]<br>
    actions: [<br>
      {<br>
        actionType: 'RemoveAllActionGroups'<br>
      }<br>
    ]<br>
    conditions: [<br>
      {<br>
        field: 'severity'<br>
        operator: 'Equals'<br>
        values: [<br>
          'Sev0'<br>
          'Sev1'<br>
        ]<br>
      }<br>
    ]<br>
    schedule: {<br>
      effectiveFrom: '2025-06-01T00:00:00'<br>
      effectiveUntil: '2025-12-31T23:59:59'<br>
      timeZone: 'UTC'<br>
      recurrences: [<br>
        {<br>
          recurrenceType: 'Weekly'<br>
          daysOfWeek: ['Monday', 'Wednesday']<br>
          startTime: '09:00:00'<br>
          endTime: '17:00:00'<br>
        }<br>
      ]<br>
    }<br>
  }<br>
}<br>
</pre><br>
<p>Example configures a suppression action rule for Sev3/Sev4 alerts in the dev environment.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| actionRuleName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name for this action rule resource, required. |
| actionRuleDescription | string | <input type="checkbox"> | None | <pre>actionRuleName</pre> | Allows you to override the description for this action rule. |
| scopes | string[] | <input type="checkbox"> | None | <pre>[subscription().id]</pre> | The scope this action rule will apply to. This defaults to the whole subscription, but you can pass an array of resourceId\'s to apply to. <br>See https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep<br>Scopes are the resources that the alert processing rule will apply to. The rule will only apply to alerts that are generated from these resources.<br>Scopes are specified as resource IDs. For example, the scope for a virtual machine would be: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}`. |
| conditions | Condition[]? | <input type="checkbox" checked> | None | <pre></pre> | Example:<br>`conditions: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;field: 'Severity'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'Equals'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;values: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev2'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev3'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev1'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;}<br>]`<br>In this example the severity of the alert is checked against the values `Sev1`, `Sev2`, and `Sev3`. <br>If the severity of the alert matches any of these values, the alert will be processed according to the actions specified in the action rule.<br>If the severity of the alert does not match any of these values, the alert will be ignored and no actions will be taken. |
| actions | ActionType[] | <input type="checkbox"> | None | <pre>[<br>  {<br>    actionType: 'RemoveAllActionGroups'<br>  }<br>]</pre> | Action type for alert processing rule. Use actionType: RemoveAllActionGroups or actionType: AddActionGroups with actionGroupIds.<br>Example:<br>`actions: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;actionGroupIds: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/subscriptionId/resourceGroups/resourceGroupId/providers/microsoft.insights/actionGroups/actionGroupName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;actionType: 'AddActionGroups'<br>&nbsp;&nbsp;&nbsp;}<br>]`<br>Actions are the operations that will be performed when the alert processing rule is triggered. The actions can include sending notifications, executing webhooks, or triggering other workflows.<br>Actions are specified as an array of objects, where each object represents a specific action to be taken.<br>The action type can be one of the following:<br>- `AddActionGroups`: Adds action groups to the alert processing rule.<br>&nbsp;&nbsp;&nbsp;- actionGroupIds: An array of action group IDs to be added to the alert processing rule.<br>- `RemoveAllActionGroups`: Removes all action groups from the alert processing rule. |
| schedule | Schedule? | <input type="checkbox" checked> | None | <pre></pre> | Defines the schedule for the alert processing rule.<br>The schedule specifies when the alert processing rule will be active. It includes the start and end times, the time zone, and recurrence details. <br>Recurrences can be configured to apply on specific days of the week.<br>Example:<br>schedule: {<br>&nbsp;&nbsp;&nbsp;effectiveFrom: '2025-04-04T00:00:00'<br>&nbsp;&nbsp;&nbsp;effectiveUntil: '2025-04-05T00:00:00'<br>&nbsp;&nbsp;&nbsp;timeZone: 'UTC'<br>&nbsp;&nbsp;&nbsp;recurrences: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daysOfWeek: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Monday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Tuesday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Wednesday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Thursday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Friday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;recurrenceType: 'Weekly'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>}<br>In this example:<br>- The rule is active from April 4, 2025, to April 5, 2025.<br>- The time zone is set to UTC.<br>- The rule recurs weekly on weekdays (Monday to Friday). |
| enabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Optional. Indicates if the given action rule is enabled or disabled. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Resource tags. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| actionRuleResourceId | string | The resource ID of the Alert Processing Rule. |
| actionRuleResourceName | string | The name of the Alert Processing Rule. |

## Links
- [Bicep Action Rules Reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep)
