# activityLogAlerts

Target Scope: resourceGroup

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| activityLogAlertName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name for this activity log alert resource |
| activityLogAlertDescription | string | <input type="checkbox"> | None | <pre>activityLogAlertName</pre> | Allows you to override the scription for this activity log alert. This will default to the same value as the activity log alert name |
| actionGroups | array | <input type="checkbox" checked> | None | <pre></pre> | The actiongroups to trigger when this alert gets activated. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep |
| condition | object | <input type="checkbox" checked> | None | <pre></pre> | The condition the alert should match to actually get triggered.. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep |
| scopes | array | <input type="checkbox"> | None | <pre>[ subscription().id ]</pre> | The scope this alert will apply to. This defaults to the whole subscription, but you can pass an array of resourceId\'s to apply to. Please refer to the default Bicep documentation: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/activitylogalerts?tabs=bicep |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |
