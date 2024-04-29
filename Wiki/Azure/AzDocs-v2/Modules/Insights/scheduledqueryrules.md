# scheduledqueryrules

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="identityType">identityType</a>  | <pre>{ type: 'None' } &#124; { type: 'SystemAssigned' } &#124; { type: 'UserAssigned', userAssignedIdentities: object }</pre> | type | The identity type. This can be either `None`, a `System Assigned` or a `UserAssigned` identity. In the case of UserAssigned, the userAssignedIdentities must be set with the ResourceId of the user assigned identity resource and the identity must have at least read logs rbac rights on the resource in scope. | 

## Synopsis
Creating scheduled rules on a log source to create an alert from.

## Description
Azure Scheduled Query Rules run a query on a specified schedule and generate alerts or incidents based on the results.<br>
This resource allow defining a scheduled query rule in Azure Monitoring.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location for this resource to be upserted in. |
| scheduledQueryRuleName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the scheduled query rules resource. |
| actionGroups | array | <input type="checkbox"> | None | <pre>[]</pre> | List of Action group resource id\'s to notify users about the alert. An action group is a collection of notification preferences. |
| scheduledQueryRuleDescription | string | <input type="checkbox"> | None | <pre>scheduledQueryRuleName</pre> | The description of the scheduled query rule. |
| scheduledQueryRuleSeverity | int | <input type="checkbox"> | Value between 0-4 | <pre>3</pre> | Severity of the alert. Should be an integer between [0-4]. Value of 0 is severest. Relevant and required only for rules of the kind LogAlert. |
| evaluationFrequency | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | How often the metric alert is evaluated represented in ISO 8601 duration format.<br>Examples:<br>PT5M is 5 minutes<br>PT15M is 15 minutes<br>PT30M is 30 minutes<br>PT1H is 1 hour |
| windowSize | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | The period of time (in [ISO 8601 duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations)) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S. You always need to mention de T if something the time is needed.<br>for example:<br>P2D is 2 days<br>P5DT5M is 5 days and 5 minutes<br>PT5M is 5 minutes<br>PT1H is 1 hour |
| criteria | object | <input type="checkbox" checked> | None | <pre></pre> | The criteria to alert. The AllOf: [] is required and it cannot be empty.<br>For options & formatting please refer to [scheduledqueryrulecriteria](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria).<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;allOf: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;query: 'traces &#124; where operation_Name == "FlowRunLastJob"'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;timeAggregation: 'Count'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dimensions: []<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'GreaterThan'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;threshold: 0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;failingPeriods: {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;numberOfEvaluationPeriods: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;minFailingPeriodsToAlert: 1<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>} |
| scopes | array | <input type="checkbox" checked> | None | <pre></pre> | Scopes list should contain at least 1 resource Id.<br>Example:<br>[ appInsights.outputs.appInsightsResourceId ] |
| targetResourceTypes | array | <input type="checkbox"> | None | <pre>[]</pre> | List of resource type of the target resource(s) on which the alert is created/updated. <br>For example if the scope is a resource group and targetResourceTypes is Microsoft.Compute/virtualMachines, then a different alert will be fired for each virtual machine in the resource group which meet the alert criteria. <br>Relevant only for rules of the kind LogAlert.<br>Examples:<br>['Microsoft.OperationalInsights/workspaces'] |
| autoMitigate | bool | <input type="checkbox"> | None | <pre>true</pre> | The flag that indicates whether the alert should be automatically resolved or not. The default is true. Relevant only for rules of the kind LogAlert. |
| muteActionsDuration | string | <input type="checkbox"> | None | <pre>''</pre> | Mute actions for the chosen period of time (in ISO 8601 duration format) after the alert is fired. Relevant only for rules of the kind LogAlert.<br>Defaults to an empty string.<br>Examples: <br>PT1M is 1 minute<br>PT5M is 5 minutes<br>PT30M is 30 minutes<br>PT1H is 1 hour |
| checkWorkspaceAlertsStorageConfigured | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether to check linked storage and fail creation if the storage was not found |
| isEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Specifies whether the alert is enabled |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| scheduledQueryRuleKind | string | <input type="checkbox"> | `'LogAlert'` or `'LogToMetric'` | <pre>'LogAlert'</pre> | Indicates the type of scheduled query rule. The default is LogAlert. |
| identity | [identityType](#identityType) | <input type="checkbox"> | None | <pre>{<br>  type: 'None'<br>}</pre> | Sets the identity. This can be either `None`, a `System Assigned` or a `UserAssigned` identity.<br>Defaults no identity.<br>If type is `UserAssigned`, then userAssignedIdentities must be set with the ResourceId of the user assigned identity resource<br>and the identity must have at least read logs rbac rights on the resource in scope.<br><details><br>&nbsp;&nbsp;&nbsp;<summary>Click to show example</summary><br><pre><br>{<br>&nbsp;&nbsp;&nbsp;type: 'UserAssigned'<br>&nbsp;&nbsp;&nbsp;userAssignedIdentities: userAssignedIdentityId :{}<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'SystemAssigned'<br>},<br>{<br>&nbsp;&nbsp;&nbsp;type: 'None'<br>}<br></pre><br></details> |
| ruleResolveConfiguration | object | <input type="checkbox"> | None | <pre>{}</pre> | Defines the configuration for resolving fired alerts. Relevant only for rules of the kind LogAlert.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;autoResolved: true //The flag that indicates whether or not to auto resolve a fired alert.<br>&nbsp;&nbsp;&nbsp;timeToResolve: 'PT1H' //The duration a rule must evaluate as healthy before the fired alert is automatically resolved represented in ISO 8601 duration format.<br>} |
| skipQueryValidation | bool | <input type="checkbox"> | None | <pre>false</pre> | The flag which indicates whether the provided query should be validated or not. The default is false. Relevant only for rules of the kind LogAlert. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| scheduledQueryRuleName | string | Output the resource name of the upserted scheduledQueryRule. |
| scheduledQueryRuleResourceId | string | Output the resource ID of the upserted scheduledQueryRule. |
| scheduledQueryRuleIdentity | string | Output the identity object ID of the upserted scheduledQueryRule. |

## Examples
<pre>
module scheduledqueryrules_50x_log_alert 'br:acrazdocsprd.azurecr.io/insights/scheduledqueryrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 51), 'schedqryrule')
  scope: resourceGroup(logAnalyticsResourceGroupName)
  params: {
    location: location
    scheduledQueryRuleName: 'scheduledqueryrules_50x_log_alert'
    scheduledQueryRuleDescription: '50X errors on POD proxy container'
    scheduledQueryRuleSeverity: 3
    isEnabled: true
    evaluationFrequency: 'PT5M'
    scopes: [
      '/subscriptions/<subscriptionId>/resourceGroups/<rgname>/providers/Microsoft.ContainerService/managedClusters/<clustername>'
    ]
    targetResourceTypes: [
      'Microsoft.ContainerService/managedClusters'
    ]
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          query: '// 50x errors are a sign that something is broken  \nContainerLogV2\n| where ContainerName == "proxy"\n| where LogMessage contains " 500 " or LogMessage contains " 501 " or LogMessage contains " 502 " or LogMessage contains " 503 " or LogMessage contains " 504 "\n\n\n'
          timeAggregation: 'Count'
          dimensions: []
          operator: 'GreaterThan'
          threshold: 5
          failingPeriods: {
            numberOfEvaluationPeriods: 5
            minFailingPeriodsToAlert: 3
          }
        }
      ]
    }
    autoMitigate: false
  }
  dependsOn: [
    loganalytics
  ]
}
</pre>
<p>Creates a scheduled rules resource with the name 'scheduledqueryrules_50x_log_alert'</p>

## Links
- [Bicep Scheduled Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep)
