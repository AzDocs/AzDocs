# metricAlerts

Target Scope: resourceGroup

## Synopsis
Creating metric alerts in Azure Monitor.

## Description
Creating metric alerts in Azure Monitor.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| metricAlertsName | string | <input type="checkbox" checked> | None | <pre></pre> | The name for the MetricAlert. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| metricAlertActionGroupId | string | <input type="checkbox"> | None | <pre>''</pre> | The id of the action group to use. |
| metricAlertWebHookProperties | object | <input type="checkbox"> | None | <pre>{}</pre> | This field allows specifying custom properties, which would be appended to the alert payload sent as input to the webhook. |
| metricAlertAutoMitigate | bool | <input type="checkbox"> | None | <pre>true</pre> | The flag that indicates whether the alert should be auto resolved or not. The default is true. |
| scopes | array | <input type="checkbox"> | None | <pre>[ subscription().id ]</pre> | the list of resource id\'s that this metric alert is scoped to. |
| metricAlertEvaluationFrequency | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | How often the metric alert is evaluated represented in ISO 8601 duration format.<br>Examples:<br>PT5M is 5 minutes<br>PT15M is 15 minutes<br>PT30M is 30 minutes<br>PT1H is 1 hour |
| metricAlertsEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | Create the metric alerts as either enabled or disabled |
| windowSize | string | <input type="checkbox"> | None | <pre>'PT5M'</pre> | The period of time (in [ISO 8601 duration format](https://en.wikipedia.org/wiki/ISO_8601#Durations)) on which the Alert query will be executed (bin size). Relevant and required only for rules of the kind LogAlert.<br>The format for this string is P<days>DT<hours>H<minutes>M<seconds>S. You always need to mention de T if something the time is needed.<br>for example:<br>P2D is 2 days<br>P5DT5M is 5 days and 5 minutes<br>PT5M is 5 minutes<br>PT1H is 1 hour |
| alertSeverity | string | <input type="checkbox"> | `'Critical'` or `'Error'` or `'Warning'` or `'Informational'` or `'Verbose'` | <pre>'Informational'</pre> |  |
| metricAlertsCriteria | object | <input type="checkbox" checked> | None | <pre></pre> | The criteria to alert.  The AllOf: [] is required and it cannot be empty.<br>For options & formatting please refer to [scheduledqueryrulecriteria](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria).<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;allOf: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;criterionType: 'StaticThresholdCriterion'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dimensions: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'controllerName'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'Include'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;values: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'*'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'kubernetes namespace'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'Include'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;values: [<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'*'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metricName: 'completedJobsCount'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;metricNamespace: 'Insights.Container/pods'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;name: 'Metric1'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;operator: 'GreaterThan'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;threshold: 0<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;timeAggregation: 'Average'<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;skipMetricValidation: true<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;]<br>&nbsp;&nbsp;&nbsp;'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'<br>} |
| metricAlertsDescription | string | <input type="checkbox"> | None | <pre>metricAlertsName</pre> | The description of the metric alert. |
| targetResourceType | string | <input type="checkbox"> | None | <pre>''</pre> | The resourcetype to have metric alerts on<br>Example:<br>'microsoft.containerservice/managedclusters' |
| targetResourceRegion | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The region of the target resource(s) on which the alert is created/updated. Mandatory if the scope contains a subscription, resource group, or more than one resource. |

## Examples
<pre>
module metricAlertCpu '../AzDocs/src-bicep/Insights/metricAlerts.bicep' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'akscpumetricalert')
  scope: resourceGroup(aksResourceGroupName)
  params: {
    metricAlertsName: 'Node CPU utilization high for ${aksName}'
    scopes: [aks.outputs.aksResourceId]
    metricAlertsCriteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'oomKilledContainerCount'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria' }
    targetResourceRegion: location
    targetResourceType: 'microsoft.containerservice/managedclusters'
  }
  dependsOn: [aks]
}
</pre>
<p>Creates a metric alert on a resource in azure monitor with the name 'Node CPU utilization high for ${aksName}'</p>

## Links
- [Bicep Metric Alerts](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/metricalerts?pivots=deployment-language-bicep)
