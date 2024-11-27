/*
.SYNOPSIS
Creating a Smart Detector Alert Rule. 
.DESCRIPTION
Creating a Smart Detector Alert Rule. Can be used to create the new type of Azure Monitor Application Insights smart detection rules (alerts view (preview)).
<pre>
module smartrules 'br:contosoregistry.azurecr.io/alertsmanagement/smartdetectoralertrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 53), 'smartrules')
  params: {
    appInsightsName: appInsights.outputs.appInsightsName
    smartDetectorAlertRuleDescription: 'Dependency Latency Degradation notifies you of an unusual increase in response by a dependency your app is calling (e.g. REST API or database).'
    smartDetectorAlertRuleDetectorId: 'DependencyPerformanceDegradationDetector'
    smartDetectorAlertRuleName: 'Failure Anomalies - ${applicationInsightsName}'
    smartDetectorAlertRuleFrequency: 'P1D'
  }
}
</pre>
<p>Creates a smart detection rule with the name 'DependencyPerformanceDegradationDetector' and displayname 'Dependency Latency Degradation - appinsights-dev'.</p>
.LINKS
- [Bicep Smart Detection Alert Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules?pivots=deployment-language-bicep)
*/
// ===================================== Parameters =====================================
@description('The resource name as shown in the Azure Portal.')
@minLength(1)
param smartDetectorAlertRuleName string

@description('The location for this resource to be upserted in.')
param location string = 'global'

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object = {}

@description('An optional custom email subject to use in email notifications.')
param actionGroupsCustomEmailSubject string = ''

@description('An optional custom web-hook payload to use in web-hook notifications.')
param actionGroupsCustomWebhookPayload string = ''

@description('An array of Action Group resource IDs to associate with the alert rule.')
param actionGroupsGroupIds array = []

@description('The description of the smart detector alert rule.')
param smartDetectorAlertRuleDescription string

@description('The internal name of the Alert rule detector. Limited to the [following:](https://learn.microsoft.com/en-gb/azure/azure-monitor/alerts/alerts-smart-detections-migration#manage-alert-rule-settings-by-using-arm-templates)')
@allowed([
  'FailureAnomaliesDetector'
  'RequestPerformanceDegradationDetector'
  'DependencyPerformanceDegradationDetector'
  'ExceptionVolumeChangedDetector'
  'TraceSeverityDetector'
  'MemoryLeakDetector'
])
param smartDetectorAlertRuleDetectorId string

@description('The alert rule frequency in ISO8601 format. The time granularity must be in minutes and minimum value is 1 minute, depending on the detector.')
param smartDetectorAlertRuleFrequency string = 'PT1M'

@description('The severity of the alert rule.')
@allowed([
  'Sev0'
  'Sev1'
  'Sev2'
  'Sev3'
  'Sev4'
])
param smartDetectorAlertRuleSeverity string = 'Sev3'

@description('The state of the alert rule.')
@allowed([
  'Enabled'
  'Disabled'
])
param smartDetectorAlertRuleState string = 'Enabled'

@description('''
The throttling settings for the smart detector alert rule. The required duration (in ISO8601 format) to wait before notifying on the alert rule again. The time granularity must be in minutes and minimum value is 0 minutes
Example:
{
  duration: 'PT5M'
}
''')
param smartDetectorAlertRuleThrottling object = {}

@description('The detector parameters for the alert rule.')
param smartDetectorAlertRuleDetectorParameters object = {}

@description('The name of the existing Application Insights instance the data for the alert is found in.')
param appInsightsName string

// ===================================== Resources =====================================
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource smartDetectorAlertRule 'microsoft.alertsManagement/smartDetectorAlertRules@2021-04-01' = {
  name: smartDetectorAlertRuleName
  location: location
  tags: tags
  properties: {
    actionGroups: {
      customEmailSubject: empty(actionGroupsCustomEmailSubject) ? null : actionGroupsCustomEmailSubject
      customWebhookPayload: empty(actionGroupsCustomWebhookPayload) ? null : actionGroupsCustomWebhookPayload
      groupIds: actionGroupsGroupIds
    }
    description: smartDetectorAlertRuleDescription
    detector: {
      id: smartDetectorAlertRuleDetectorId
      parameters: empty(smartDetectorAlertRuleDetectorParameters) ? null : smartDetectorAlertRuleDetectorParameters
    }
    frequency: smartDetectorAlertRuleFrequency
    scope: [
      applicationInsights.id
    ]
    severity: smartDetectorAlertRuleSeverity
    state: smartDetectorAlertRuleState
    throttling: empty(smartDetectorAlertRuleThrottling) ? null : smartDetectorAlertRuleThrottling
  }
}

// ===================================== Outputs =====================================
@description('The Resource ID of the upserted smart detector alert rule.')
output smartDetectorAlertRuleId string = smartDetectorAlertRule.id
@description('The name of the upserted smart detector alert rule.')
output smartDetectorAlertRuleName string = smartDetectorAlertRule.name
