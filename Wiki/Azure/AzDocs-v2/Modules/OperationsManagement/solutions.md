# solutions

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| logAnalyticsWorkspaceName | string | <input type="checkbox" checked> | Length between 4-63 | <pre></pre> | Specifies the name of the Log Analytics workspace. This LAW should be pre-existing. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
| AuthoredBy | string | <input type="checkbox"> | `'Microsoft'` or `'ThirdParty'` | <pre>'Microsoft'</pre> | Who is authoring this solution type. Can be either `Microsoft` or `ThirdParty`. |
| solutionProduct | string | <input type="checkbox" checked> | None | <pre></pre> | The solution type to upsert. NOTE: This is case-sensitive.<br><br>Most used options are:<br>SecurityCenterFree, Security, Updates, ContainerInsights, ServiceMap, AzureActivity, ChangeTracking, VMInsights, SecurityInsights, NetworkMonitoring, SQLVulnerabilityAssessment, SQLAdvancedThreatProtection, AntiMalware, AzureAutomation, LogicAppsManagement, SQLDataClassification. |
| Publisher | string | <input type="checkbox"> | None | <pre>'Microsoft'</pre> | Allows you to override the publisher for the plan. |
