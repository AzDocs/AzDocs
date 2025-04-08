# actionRule

Target Scope: resourceGroup

## Synopsis
Creating a Alert Processing Rule. 

## Description
Creating a Alert Processing Alert Rule, used for management of alert rules.<br>
<pre><br>
module smartrules 'br:contosoregistry.azurecr.io/alertsmanagement/actionrule:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 54), 'actionrule')<br>
  params: {<br>
    actions: actions<br>
    actionRuleDescription: 'My alert processing rule'<br>
    actionRuleName: 'apr-myrule-tst'<br>
    conditions: !empty(conditions) ? conditions : null<br>
    isEnabled: isEnabled<br>
    schedule: schedule<br>
    scopes: scopes<br>
    tags: tags<br>
  }<br>
}<br>
</pre><br>
<p>Creates an alert processing rule with the name 'apr-myrule-tst' and displayname 'My alert processing rule'.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| actions | array | <input type="checkbox" checked> | None | <pre></pre> | <br>Example:<br>`actions: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;actionGroupIds: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'/subscriptions/subscriptionId/resourceGroups/resourceGroupId/providers/microsoft.insights/actionGroups/actionGroupName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;actionType: 'AddActionGroups'<br>&nbsp;&nbsp;&nbsp;}<br>]`<br><br>Actions are the operations that will be performed when the alert processing rule is triggered. The actions can include sending notifications, executing webhooks, or triggering other workflows.<br>Actions are specified as an array of objects, where each object represents a specific action to be taken.<br>The action type can be one of the following:<br>- `AddActionGroups`: Adds action groups to the alert processing rule.<br>&nbsp;&nbsp;&nbsp;- actionGroupIds: An array of action group IDs to be added to the alert processing rule.<br>- `RemoveAllActionGroups`: Removes all action groups from the alert processing rule. |
| actionRuleDescription | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Description of alert processing rule. |
| actionRuleName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The name of the action rule. |
| conditions | array? | <input type="checkbox" checked> | None | <pre></pre> | <br>Example:<br>`conditions: [<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;field: 'Severity'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'Equals'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;values: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev2'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev3'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Sev1'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;}<br>]`<br><br>In this example the severity of the alert is checked against the values `Sev1`, `Sev2`, and `Sev3`. If the severity of the alert matches any of these values, the alert will be processed according to the actions specified in the action rule.<br>If the severity of the alert does not match any of these values, the alert will be ignored and no actions will be taken. |
| isEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Indicates if the given alert processing rule is enabled or disabled. |
| scopes | string[] | <input type="checkbox" checked> | None | <pre></pre> | <br>Scopes are the resources that the alert processing rule will apply to. The rule will only apply to alerts that are generated from these resources.<br>Scopes are specified as resource IDs. For example, the scope for a virtual machine would be: `/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Compute/virtualMachines/{virtualMachineName}`. |
| schedule | object? | <input type="checkbox" checked> | None | <pre></pre> | <br>The schedule specifies when the alert processing rule will be active. It includes the start and end times, the time zone, and recurrence details. Recurrences can be configured to apply on specific days of the week.<br><br>Example:<br>schedule: {<br>&nbsp;&nbsp;&nbsp;effectiveFrom: '2025-04-04T00:00:00'<br>&nbsp;&nbsp;&nbsp;effectiveUntil: '2025-04-05T00:00:00'<br>&nbsp;&nbsp;&nbsp;timeZone: 'UTC'<br>&nbsp;&nbsp;&nbsp;recurrences: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daysOfWeek: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Monday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Tuesday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Wednesday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Thursday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'Friday'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;recurrenceType: 'Weekly'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>}<br><br>In this example:<br>- The rule is active from April 4, 2025, to April 5, 2025.<br>- The time zone is set to UTC.<br>- The rule recurs weekly on weekdays (Monday to Friday). |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| actionRuleId | string | The resource ID of the action rule. |
| actionRuleName | string | The name of the action rule. |

## Links
- [Bicep Action Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/actionrules?pivots=deployment-language-bicep#recurrence)
