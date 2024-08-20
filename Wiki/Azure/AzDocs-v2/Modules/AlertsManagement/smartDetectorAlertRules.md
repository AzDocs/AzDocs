# smartDetectorAlertRules

Target Scope: resourceGroup

## Synopsis
Creating a Smart Detector Alert Rule. 

## Description
Creating a Smart Detector Alert Rule. Can be used to create the new type of Azure Monitor Application Insights smart detection rules (alerts view (preview)).<br>
<pre><br>
module smartrules 'br:contosoregistry.azurecr.io/alertsmanagement/smartdetectoralertrules:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 53), 'smartrules')<br>
  params: {<br>
    appInsightsName: appInsights.outputs.appInsightsName<br>
    smartDetectorAlertRuleDescription: 'Dependency Latency Degradation notifies you of an unusual increase in response by a dependency your app is calling (e.g. REST API or database).'<br>
    smartDetectorAlertRuleDetectorId: 'DependencyPerformanceDegradationDetector'<br>
    smartDetectorAlertRuleName: 'Failure Anomalies - ${applicationInsightsName}'<br>
    smartDetectorAlertRuleFrequency: 'P1D'<br>
  }<br>
}<br>
</pre><br>
<p>Creates a smart detection rule with the name 'DependencyPerformanceDegradationDetector' and displayname 'Dependency Latency Degradation - appinsights-dev'.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| smartDetectorAlertRuleName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The resource name as shown in the Azure Portal. |
| location | string | <input type="checkbox"> | None | <pre>'global'</pre> | The location for this resource to be upserted in. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| actionGroupsCustomEmailSubject | string | <input type="checkbox"> | None | <pre>''</pre> | An optional custom email subject to use in email notifications. |
| actionGroupsCustomWebhookPayload | string | <input type="checkbox"> | None | <pre>''</pre> | An optional custom web-hook payload to use in web-hook notifications. |
| actionGroupsGroupIds | array | <input type="checkbox"> | None | <pre>[]</pre> | An array of Action Group resource IDs to associate with the alert rule. |
| smartDetectorAlertRuleDescription | string | <input type="checkbox" checked> | None | <pre></pre> | The description of the smart detector alert rule. |
| smartDetectorAlertRuleDetectorId | string | <input type="checkbox" checked> | `'FailureAnomaliesDetector'` or `'RequestPerformanceDegradationDetector'` or `'DependencyPerformanceDegradationDetector'` or `'ExceptionVolumeChangedDetector'` or `'TraceSeverityDetector'` or `'MemoryLeakDetector'` | <pre></pre> | The internal name of the Alert rule detector. Limited to the [following:](https://learn.microsoft.com/en-gb/azure/azure-monitor/alerts/alerts-smart-detections-migration#manage-alert-rule-settings-by-using-arm-templates) |
| smartDetectorAlertRuleFrequency | string | <input type="checkbox"> | None | <pre>'PT1M'</pre> | The alert rule frequency in ISO8601 format. The time granularity must be in minutes and minimum value is 1 minute, depending on the detector. |
| smartDetectorAlertRuleSeverity | string | <input type="checkbox"> | `'Sev0'` or `'Sev1'` or `'Sev2'` or `'Sev3'` or `'Sev4'` | <pre>'Sev3'</pre> | The severity of the alert rule. |
| smartDetectorAlertRuleState | string | <input type="checkbox"> | `'Enabled'` or `'Disabled'` | <pre>'Enabled'</pre> | The state of the alert rule. |
| smartDetectorAlertRuleThrottling | object | <input type="checkbox"> | None | <pre>{}</pre> | The throttling settings for the smart detector alert rule. The required duration (in ISO8601 format) to wait before notifying on the alert rule again. The time granularity must be in minutes and minimum value is 0 minutes<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;duration: 'PT5M'<br>} |
| smartDetectorAlertRuleDetectorParameters | object | <input type="checkbox"> | None | <pre>{}</pre> | The detector parameters for the alert rule. |
| appInsightsName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the existing Application Insights instance the data for the alert is found in. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| smartDetectorAlertRuleId | string | The Resource ID of the upserted smart detector alert rule. |
| smartDetectorAlertRuleName | string | The name of the upserted smart detector alert rule. |

## Links
- [Bicep Smart Detection Alert Rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.alertsmanagement/smartdetectoralertrules?pivots=deployment-language-bicep)
