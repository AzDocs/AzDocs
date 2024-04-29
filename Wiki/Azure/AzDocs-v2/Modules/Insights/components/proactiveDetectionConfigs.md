# proactiveDetectionConfigs

Target Scope: resourceGroup

## Synopsis
Creating a Proactive Detection Config.

## Description
Creating a Proactive Detection Config.<br>
<pre><br>
module apim 'br:contosoregistry.azurecr.io/insights/components/proactiveDetectionConfigs.bicep' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 32), 'degradationindependencyduration')<br>
  dependsOn: [<br>
    applicationInsights<br>
  ]<br>
  params: {<br>
    name: 'degradationindependencyduration'<br>
    displayName: 'Degradation in dependency duration'<br>
    ruleDescription: 'Smart Detection rules notify you of performance anomaly issues.'<br>
    helpUrl: 'https://docs.microsoft.com/en-us/azure/application-insights/app-insights-proactive-performance-diagnostics'<br>
    applicationInsightsName: applicationInsights.outputs.appInsightsName<br>
    customEmails: customEmails<br>
  }<br>
}<br>
</pre><br>
<p>Creates a smart detection rule with the name displayName that is integrated in applicationInsights.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| name | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The resource name |
| displayName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The rule name as it is displayed in UI |
| isRuleEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | 	A flag that indicates whether this rule is enabled by the user |
| ruleDescription | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The rule description |
| helpUrl | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | URL which displays additional info about the proactive detection rule |
| IsEnabledByDefault | bool | <input type="checkbox"> | None | <pre>true</pre> | 	A flag indicating whether the rule is enabled by default |
| isHiddenFromUI | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag indicating whether the rule is hidden (from the UI) |
| IsInPreview | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag indicating whether the rule is in preview |
| SupportsEmailNotifications | bool | <input type="checkbox"> | None | <pre>true</pre> | A flag indicating whether email notifications are supported for detections for this rule |
| applicationInsightsName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | Parent Application Insights resource |
| customEmails | array | <input type="checkbox"> | None | <pre>[ ]</pre> | Additional email recipients for smart detection notification |
| SendEmailsToSubscriptionOwners | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag that indicated whether notifications on this rule should be sent to subscription owners |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| proActiveDetectionConfigId | string | The Resource ID of the upserted proactive detection config. |
| proActiveDetectionConfigName | string | The name of the upserted proactive detection config. |

## Links
- [Bicep Proactive Detection Configs](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2018-05-01-preview/components/proactivedetectionconfigs?pivots=deployment-language-bicep)
