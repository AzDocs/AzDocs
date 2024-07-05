# dataCollectionRules

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="roleAssignmentType">roleAssignmentType</a>  | <pre>{</pre> |  |  | 

## Synopsis
Creating a data collection rule.

## Description
Creating a data collection rule (DCR). Data collection rules (DCRs) are sets of instructions that determine how to collect and process telemetry sent to Azure Monitor.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| dataCollectionRuleName | string | <input type="checkbox" checked> | None | <pre></pre> | Required. The name of the data collection rule. The name is case insensitive. |
| dataCollectionEndpointId | string? | <input type="checkbox" checked> | None | <pre></pre> | A Data Collection Endpoint is optional for collecting Windows Event Logs, Linux Syslog or Performance Counters. It is required for all other data sources. |
| dataFlows | array | <input type="checkbox" checked> | None | <pre></pre> | Required. The specification of data flows. |
| dataSources | object | <input type="checkbox" checked> | None | <pre></pre> | Specification of data sources that will be collected. Can be empty if the parameter kind is not Linux or Windows. |
| dataCollectionRuleDescription | string? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Description of the data collection rule. |
| destinations | object | <input type="checkbox" checked> | None | <pre></pre> | Required. Specification of destinations that can be used in data flows. |
| kind | string | <input type="checkbox"> | `'Linux'` or `'Windows'` or `'Direct'` or `'WorkspaceTransforms'` or `'AgentDirectToStore'` or `'AgentSettings'` or `'PlatformTelemetry'` | <pre>'Linux'</pre> | The kind of the resource. In the Portal this is represented as Platform Type. Additional undocumented but supported values are: Direct, WorkspaceTransforms,AgentDirectToStore, AgentSettings, PlatformTelemetry. |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Optional. Location for all Resources. |
| roleAssignments | [roleAssignmentType](#roleAssignmentType) | <input type="checkbox" checked> | None | <pre></pre> | Optional. Array of role assignments to create. |
| streamDeclarations | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Declaration of custom streams used in this rule. |
| tags | object? | <input type="checkbox" checked> | None | <pre></pre> | Optional. Resource tags. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| name | string | The name of the dataCollectionRule. |
| resourceId | string | The resource ID of the dataCollectionRule. |
| resourceGroupName | string | The name of the resource group the dataCollectionRule was created in. |
| location | string | The location the resource was deployed into. |

## Examples
<pre>
module dcrule 'br:contosoregistry.azurecr.io/insights/datacollectionrules:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'dcr')
  params: {
    dataCollectionRuleName: 'dcrname'
    dataCollectionEndpoint: '/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourceGroups/azure-azdovmss-dev/providers/Microsoft.Insights/dataCollectionEndpoints/dceprivateendpointchk'
    dataSources: {}
    kind: 'Direct'
    dataFlows: [
      {
        streams: [
          'Custom-MyTable_CL'
        ]
        destinations: [
          guid('/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev')
        ]
        outputStream: 'Custom-MyTable_CL'
        transformKql: 'source'
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: '/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev'
          name: guid('/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourcegroups/azure-azdovmss-dev/providers/microsoft.operationalinsights/workspaces/my004law-dev')
        }
      ]
    }
  }
}
</pre>
<p>Creates a data collection rule in Azure Monitor where the data is sent to a custom table in Log Analytics workspace.</p>

## Links
- [Bicep Data Collection rules](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?pivots=deployment-language-bicep)
