/*
.SYNOPSIS
Creating a data collection rule association.
.DESCRIPTION
Creating a data collection rule association.
.EXAMPLE
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
.LINKS
- [Bicep Data Collection Endpoints](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionruleassociations?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('The name of the virtual machine.')
param virtualMachineName string

@description('The name of the association.')
param dcrAssociationName string

@description('The resource ID of the data collection rule.')
param dataCollectionRuleId string

@description('The ID of a data collection endpoint.')
param dataCollectionEndpointId string?

@description('The description of the association.')
param dataCollectionRuleAssociationDescription string = 'Association of data collection rule. Deleting this association will break the data collection.'

// ===================================== Resources =====================================
resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' existing = {
  name: virtualMachineName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2023-03-11' = {
  name: dcrAssociationName
  scope: vm
  properties: {
    description: dataCollectionRuleAssociationDescription
    dataCollectionRuleId: dataCollectionRuleId
    dataCollectionEndpointId: dataCollectionEndpointId
  }
}
