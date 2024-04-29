/*
.SYNOPSIS
Creating metric alerts in Azure Monitor.
.DESCRIPTION
Creating metric alerts in Azure Monitor.
.EXAMPLE
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
.LINKS
- [Bicep Metric Alerts](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/metricalerts?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name for the MetricAlert.')
param metricAlertsName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('The id of the action group to use.')
param metricAlertActionGroupId string = ''

@description('This field allows specifying custom properties, which would be appended to the alert payload sent as input to the webhook.')
param metricAlertWebHookProperties object = {}

@description('The flag that indicates whether the alert should be auto resolved or not. The default is true.')
param metricAlertAutoMitigate bool = true

@description('the list of resource id\'s that this metric alert is scoped to.')
param scopes array = [ subscription().id ]

@description('''
How often the metric alert is evaluated represented in ISO 8601 duration format.
Examples:
PT5M is 5 minutes
PT15M is 15 minutes
PT30M is 30 minutes
PT1H is 1 hour
''')
param metricAlertEvaluationFrequency string = 'PT5M'

@description('Create the metric alerts as either enabled or disabled')
param metricAlertsEnabled bool = true

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

@allowed([
  'Critical'
  'Error'
  'Warning'
  'Informational'
  'Verbose'
])
param alertSeverity string = 'Informational'

var alertServerityLookup = {
  Critical: 0
  Error: 1
  Warning: 2
  Informational: 3
  Verbose: 4
}
var alertSeverityNumber = alertServerityLookup[alertSeverity]

@description('''
The criteria to alert.  The AllOf: [] is required and it cannot be empty.
For options & formatting please refer to [scheduledqueryrulecriteria](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/scheduledqueryrules?pivots=deployment-language-bicep#scheduledqueryrulecriteria).
Example:
{
  allOf: [
    {
      criterionType: 'StaticThresholdCriterion'
      dimensions: [
        {
          name: 'controllerName'
          operator: 'Include'
          values: [
            '*'
          ]
        }
        {
          name: 'kubernetes namespace'
          operator: 'Include'
          values: [
            '*'
          ]
        }
      ]
      metricName: 'completedJobsCount'
      metricNamespace: 'Insights.Container/pods'
      name: 'Metric1'
      operator: 'GreaterThan'
      threshold: 0
      timeAggregation: 'Average'
      skipMetricValidation: true
    }
  ]
  'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
}
''')
param metricAlertsCriteria object

@description('The description of the metric alert.')
param metricAlertsDescription string = metricAlertsName

@description('''
The resourcetype to have metric alerts on
Example:
'microsoft.containerservice/managedclusters'
''')
param targetResourceType string = ''

@description('The region of the target resource(s) on which the alert is created/updated. Mandatory if the scope contains a subscription, resource group, or more than one resource.')
param targetResourceRegion string = resourceGroup().location


resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: metricAlertsName
  location: 'global'
  tags: tags
  properties:  {
    actions: empty(metricAlertActionGroupId) ? []: [
      {
        actionGroupId: metricAlertActionGroupId
        webHookProperties: metricAlertWebHookProperties
      }
    ]
    autoMitigate: metricAlertAutoMitigate
    criteria: metricAlertsCriteria
    description: metricAlertsDescription
    enabled: metricAlertsEnabled
    evaluationFrequency: metricAlertEvaluationFrequency
    scopes: scopes
    severity: alertSeverityNumber
    targetResourceRegion: targetResourceRegion
    targetResourceType: targetResourceType
    windowSize: windowSize
  }
}
