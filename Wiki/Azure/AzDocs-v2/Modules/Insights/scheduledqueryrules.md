# scheduledqueryrules

Target Scope: resourceGroup

## Synopsis
Creating scheduled rules in Azure Monitor.

## Description
Creating scheduled rules in Azure Monitor..

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this Application Insights instance to be upserted in. |
| scheduledQueryRuleName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the scheduled query rules resource. |
| actionGroups | array | <input type="checkbox"> | None | <pre>[]</pre> | List of Action group resource id\'s to notify users about the alert. An action group is a collection of notification preferences. |
| scheduledQueryRuleDescription | string | <input type="checkbox"> | None | <pre>scheduledQueryRuleName</pre> | The description of the scheduled query rule. |
| scheduledQueryRuleSeverity | int | <input type="checkbox"> | Value between 0-4 | <pre>3</pre> | Severity of the alert. Should be an integer between [0-4]. Value of 0 is severest. Relevant and required only for rules of the kind LogAlert. |
| evaluationFrequency | string | <input type="checkbox"> | `'PT5M'` or  `'PT15M'` or  `'PT30M'` or  `'PT1H'` | <pre>'PT5M'</pre> | how often the metric alert is evaluated represented in ISO 8601 duration format |
| windowSize | string | <input type="checkbox"> | `'PT1M'` or  `'PT5M'` or  `'PT15M'` or  `'PT30M'` or  `'PT1H'` or  `'PT6H'` or  `'PT12H'` or  `'PT24H'` | <pre>'PT5M'</pre> | The period of time (in [ISO 8601 duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations)) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S. You always need to mention de T if something the time is needed.<br>for example:<br>P5D is 5 days<br>P5M is 5 months<br>P5DT5M is 5 days  and 5 minutes<br>PT5M is 5 minutes<br>PT1H is 1 hour |
| criteria | object | <input type="checkbox" checked> | None | <pre></pre> | The criteria to alert.  The AllOf: [] is required and it cannot be empty.<br>For options & formatting please refer to [scheduledqueryrulecriteria](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria).<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;allOf: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;query: 'traces &#124; where operation_Name == "FlowRunLastJob"'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;timeAggregation: 'Count'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dimensions: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'GreaterThan'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;threshold: 0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;failingPeriods: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;numberOfEvaluationPeriods: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;minFailingPeriodsToAlert: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>} |
| scopes | array | <input type="checkbox" checked> | None | <pre></pre> | Scopes list should contain at least 1 resource Id.<br>Example:<br>[ appInsights.outputs.appInsightsResourceId ] |
| targetResourceTypes | array | <input type="checkbox"> | None | <pre>[]</pre> | List of resource type of the target resource(s) on which the alert is created/updated. For example if the scope is a resource group and targetResourceTypes is Microsoft.Compute/virtualMachines, then a different alert will be fired for each virtual machine in the resource group which meet the alert criteria. Relevant only for rules of the kind LogAlert. |
| autoMitigate | bool | <input type="checkbox"> | None | <pre>true</pre> | The flag that indicates whether the alert should be automatically resolved or not. The default is true. Relevant only for rules of the kind LogAlert. |
| muteActionsDuration | string | <input type="checkbox"> | `'PT1M'` or  `'PT5M'` or  `'PT15M'` or  `'PT30M'` or  `'PT1H'` or  `'PT6H'` or  `'PT12H'` or  `'PT24H'` or  `''` | <pre>''</pre> | Mute actions for the chosen period of time (in ISO 8601 duration format) after the alert is fired. Relevant only for rules of the kind LogAlert.<br>Defaults to an empty string. |
| checkWorkspaceAlertsStorageConfigured | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether to check linked storage and fail creation if the storage was not found |
| isEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether the alert is enabled |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| scheduledQueryRuleName | string | Output the resource name of the upserted scheduledQueryRule. |
| scheduledQueryRuleResourceId | string | Output the resource ID of the upserted scheduledQueryRule. |
## Examples
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

## Links
- [Bicep Scheduled Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep)


