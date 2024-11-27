# proactiveDetectionConfigs

Target Scope: resourceGroup

## Synopsis
Configuring a Proactive Detection Config.

## Description
Configuring a Proactive Detection Config for a smart detection rule in Application Insights.<br>
<pre><br>
module proactivedetectionconfig 'br:contosoregistry.azurecr.io/insights/components/proactivedetectionconfigs:latest' = {<br>
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
<p>Configures a smart detection rule with the name 'Degradation in dependency duration' that is integrated in applicationInsights.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| name | string | <input type="checkbox" checked> | `'slowpageloadtime'` or `'slowserverresponsetime'` or `'longdependencyduration'` or `'degradationinserverresponsetime'` or `'degradationindependencyduration'` or `'extension_traceseveritydetector'` or `'extension_exceptionchangeextension'` or `'extension_memoryleakextension'` or `'extension_securityextensionspackage'` or `'extension_canaryextension'` or `'extension_billingdatavolumedailyspikeextension'` or `'digestMailConfiguration'` or `'migrationToAlertRulesCompleted'` | <pre></pre> | The internal resource name for the proactive detection rule you want to set the config to. |
| displayName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The rule name as it is displayed in UI |
| isRuleEnabled | bool | <input type="checkbox"> | None | <pre>true</pre> | A flag that indicates whether this rule is enabled by the user |
| ruleDescription | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | The rule description |
| helpUrl | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | URL which displays additional info about the proactive detection rule |
| IsEnabledByDefault | bool | <input type="checkbox"> | None | <pre>true</pre> | A flag indicating whether the rule is enabled by default |
| isHiddenFromUI | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag indicating whether the rule is hidden (from the UI) |
| IsInPreview | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag indicating whether the rule is in preview |
| SupportsEmailNotifications | bool | <input type="checkbox"> | None | <pre>true</pre> | A flag indicating whether email notifications are supported for detections for this rule |
| applicationInsightsName | string | <input type="checkbox" checked> | None | <pre></pre> | Existing parent Application Insights resource |
| customEmails | array | <input type="checkbox"> | None | <pre>[]</pre> | Additional email recipients for smart detection notification |
| SendEmailsToSubscriptionOwners | bool | <input type="checkbox"> | None | <pre>false</pre> | A flag that indicated whether notifications on this rule should be sent to subscription owners |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| proActiveDetectionConfigId | string | The Resource ID of the upserted proactive detection config. |
| proActiveDetectionConfigName | string | The name of the upserted proactive detection config. |

## Links
- [Bicep Proactive Detection Configs](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2018-05-01-preview/components/proactivedetectionconfigs?pivots=deployment-language-bicep)
