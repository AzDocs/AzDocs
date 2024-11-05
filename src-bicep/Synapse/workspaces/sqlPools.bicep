/*
.SYNOPSIS
Create a Synapse Workspace sql pool.
.DESCRIPTION
Create a Synapse Workspace sql pool with the given specs.
.EXAMPLE
<pre>
module synapsesqlpool 'br:contosoregistry.azurecr.io/synapse/workspaces/sqlpools:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapsesqlpls')
  params: {
    synapseWorkSpaceName: 'synapsews'
    sqlpoolName: 'synsqlpool2'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace Sql Pool.</p>
.LINKS
- [Bicep Microsoft.Synapse workspaces sql pools](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/sqlpools?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Name of the Synapse SQL Pool.')
@minLength(1)
@maxLength(60)
param sqlpoolName string

@description('''
The tags to apply to this resource. This is an object with key/value pairs.
Example:
{
  FirstTag: myvalue
  SecondTag: another value
}
''')
param tags object?

@description('Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Required. Name of the existing Synapse Workspace.')
param synapseWorkSpaceName string

@description('Specifies the collation of the Synapse SQL Pool.')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Specifies the SKU of the Synapse SQL Pool.')
param sqlPoolsSkuName string = 'DW100c'

@description('Specifies the mode of sql pool creation. For details see [link](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/sqlpools?pivots=deployment-language-bicep#sqlpoolresourceproperties)')
@allowed([
  'Default'
  'PointInTimeRestore'
  'Recovery'
  'Restore'
])
param sqlPoolsCreateMode string = 'Default'

// ================================================= Existing Resources ========================================
@description('Existing Synapse Workspace')
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkSpaceName
}

// ================================================= Resources =================================================
resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-06-01' = {
  name: sqlpoolName
  location: location
  parent: synapseWorkspace
  tags: tags
  sku: {
    name: sqlPoolsSkuName
  }
  properties: {
    collation: collation
    createMode: sqlPoolsCreateMode
  }
}
