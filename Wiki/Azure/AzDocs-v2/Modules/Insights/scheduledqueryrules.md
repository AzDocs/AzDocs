# scheduledqueryrules

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this Application Insights instance to be upserted in. |
| scheduledQueryRuleName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the scheduled query rules resource. |
| actionGroups | array | <input type="checkbox"> | None | <pre>[]</pre> | List of Action group resource id\'s to notify users about the alert. An action group is a collection of notification preferences. |
| scheduledQueryRuleDescription | string | <input type="checkbox"> | None | <pre>scheduledQueryRuleName</pre> | The description of the scheduled query rule. |
| scheduledQueryRuleSeverity | int | <input type="checkbox"> | Value between 0-4 | <pre>3</pre> | Severity of the alert. Should be an integer between [0-4]. Value of 0 is severest. Relevant and required only for rules of the kind LogAlert. |
| evaluationFrequency | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | How often the scheduled query rule is evaluated represented in ISO 8601 duration format. Relevant and required only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).<br>Defaults to PT5M. |
| windowSize | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | The period of time (in ISO 8601 duration format) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).<br>Defaults to PT5M. |
| criteria | array | <input type="checkbox"> | None | <pre>[]</pre> | The criteria to alert. For options & formatting please refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria.<br>Example:<br>[<br>&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;failingPeriods: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;minFailingPeriodsToAlert: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;numberOfEvaluationPeriods: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'GreaterThan'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;query: '<input query here>'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;threshold: 0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;resourceIdColumn: ''<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;timeAggregation: 'Count'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dimensions: []<br>&nbsp;&nbsp;&nbsp;}<br>] |
| scopes | array | <input type="checkbox"> | None | <pre>[]</pre> | The list of resource id\'s that this scheduled query rule is scoped to. |
| targetResourceTypes | array | <input type="checkbox"> | None | <pre>[]</pre> | List of resource type of the target resource(s) on which the alert is created/updated. For example if the scope is a resource group and targetResourceTypes is Microsoft.Compute/virtualMachines, then a different alert will be fired for each virtual machine in the resource group which meet the alert criteria. Relevant only for rules of the kind LogAlert. |
| autoMitigate | bool | <input type="checkbox"> | None | <pre>true</pre> | The flag that indicates whether the alert should be automatically resolved or not. The default is true. Relevant only for rules of the kind LogAlert. |
| muteActionsDuration | string | <input type="checkbox"> | None | <pre>''</pre> | Mute actions for the chosen period of time (in ISO 8601 duration format) after the alert is fired. Relevant only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes).<br>Defaults to an empty string. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| scheduledQueryRuleName | string | Output the resource name of the upserted scheduledQueryRule. |
| scheduledQueryRuleResourceId | string | Output the resource ID of the upserted scheduledQueryRule. |

