# dataCollectionRuleAssociations

Target Scope: resourceGroup

## Synopsis
Creating a data collection rule association.

## Description
Creating a data collection rule association.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| virtualMachineName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the virtual machine. |
| dcrAssociationName | string | <input type="checkbox" checked> | None | <pre></pre> | The name of the association. |
| dataCollectionRuleId | string | <input type="checkbox" checked> | None | <pre></pre> | The resource ID of the data collection rule. |
| dataCollectionEndpointId | string? | <input type="checkbox" checked> | None | <pre></pre> | The ID of a data collection endpoint. |
| dataCollectionRuleAssociationDescription | string | <input type="checkbox"> | None | <pre>'Association of data collection rule. Deleting this association will break the data collection.'</pre> | The description of the association. |

## Examples
<pre>
module dcrassocation 'br:contosoregistry.azurecr.io/insights/datacollectionruleassociations:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 60), 'dca')
  params: {
    virtualMachineName: 'vmname'
    dcrAssociationName: 'dcaname'
    dataCollectionRuleId: '/subscriptions/9f64b7b1-676f-4514-9fa2-70274c6ce423/resourceGroups/azure-azdovmss-dev/providers/Microsoft.Insights/dataCollectionRules/dcrname'
  }
}
</pre>
<p>Creates a data collection rule association in Azure Monitor.</p>

## Links
- [Bicep Data Collection Endpoints](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionruleassociations?pivots=deployment-language-bicep)
