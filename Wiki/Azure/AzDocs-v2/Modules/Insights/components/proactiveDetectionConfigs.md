# proactiveDetectionConfigs

Target Scope: resourceGroup

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
| applicationInsightsName | string | <input type="checkbox" checked> | Length between 1-* | <pre></pre> | Parent Application Insights resource |
| smartDetectionEmailRecipients | string | <input type="checkbox" checked> | None | <pre></pre> | Additional email recipients for smart detection notification, separated by semicolons. |
| SendEmailsToSubscriptionOwners | bool | <input type="checkbox"> | None | <pre>true</pre> | A flag that indicated whether notifications on this rule should be sent to subscription owners |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| proActiveDetectionConfigId | string | The Resource ID of the upserted proactive detection config. |
| proActiveDetectionConfigName | string | The name of the upserted proactive detection config. |
