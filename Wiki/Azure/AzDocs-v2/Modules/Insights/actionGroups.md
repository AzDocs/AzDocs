# actionGroups

Target Scope: resourceGroup

## Synopsis
Creating an Action Group.

## Description
Creating an Action Group for Azure Monitor.<br>
<pre><br>
module action group 'br:contosoregistry.azurecr.io/insights/actiongroups:latest' = {<br>
  name: format('{0}-{1}', take('${deployment().name}', 52), 'actiongroup')<br>
  params: {<br>
    actionGroupName: 'ag-appl-dev'<br>
    groupShortName: 'agappldev'<br>
    emailReceivers: [<br>
        {<br>
            name: 'testemailfunction'<br>
            emailAddress: 'first.last@email.com'<br>
            useCommonAlertSchema: false<br>
            status: 'Enabled'<br>
        }<br>
    ]<br>
  }<br>
}<br>
</pre><br>
<p>Configures a smart detection rule with the name 'Degradation in dependency duration' that is integrated in applicationInsights.</p>

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| actionGroupName | string | <input type="checkbox" checked> | Length between 1-260 | <pre></pre> | The name of the actionGroup to upsert. |
| groupShortName | string | <input type="checkbox" checked> | Length between 0-12 | <pre></pre> | Short name up to 12 characters for the Action group |
| emailReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of emailReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#emailreceiver for documentation. |
| webhookReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of webhookReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#webhookreceiver for documentation. |
| voiceReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of voiceReceivers to receive alerts for this alertGroup using Voicecalls. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#voicereceiver for documentation. |
| smsReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of smsReceivers to receive alerts for this alertGroup using SMS. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#smsreceiver for documentation. |
| logicAppReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of logicAppReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#logicappreceiver for documentation. |
| itsmReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of itsmReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#itsmreceiver for documentation. |
| azureFunctionReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of azureFunctionReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#azurefunctionreceiver for documentation. |
| azureAppPushReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of azureAppPushReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#azureapppushreceiver for documentation. |
| automationRunbookReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of automationRunbookReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#automationrunbookreceiver for documentation. |
| armRoleReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of armRoleReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#armrolereceiver for documentation. |
| eventHubReceivers | array | <input type="checkbox"> | None | <pre>[]</pre> | Array of eventHubReceivers to receive alerts for this alertGroup. See https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/actiongroups?tabs=bicep#eventhubreceiver for documentation. |
| tags | object | <input type="checkbox"> | None | <pre>{}</pre> | The tags to apply to this resource. This is an object with key/value pairs.<br>Example:<br>{<br>&nbsp;&nbsp;&nbsp;FirstTag: myvalue<br>&nbsp;&nbsp;&nbsp;SecondTag: another value<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| actionGroupResourceId | string | The Resource ID of the upserted action group |
| actionGroupName | string | The name of the upserted action group |

## Links
- [Bicep Proactive Detection Configs](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/2018-05-01-preview/components/proactivedetectionconfigs?pivots=deployment-language-bicep)
