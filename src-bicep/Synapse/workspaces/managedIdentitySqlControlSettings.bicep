/*
.SYNOPSIS
Create a Synapse workspaces managed identity sqlcontrolsettings.
.DESCRIPTION
Create a Synapse workspaces managed identity sqlcontrolsettings with the given specs.
.EXAMPLE
<pre>
module synapsemanidsqlctl 'br:contosoregistry.azurecr.io/synapse/workspaces/managedidentitysqlcontrolsettings:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 46), 'synapsemaidsqlctl')
  params: {
    synapseWorkSpaceName: 'synapsews'
    desiredStateGrantSqlControlToManagedIdentity: 'Enabled'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace Sql Pool.</p>
.LINKS
- [Bicep Microsoft.Synapse workspaces managed identity sqlcontrolsettings](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/managedidentitysqlcontrolsettings?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Required. Name of the existing Synapse Workspace.')
param synapseWorkSpaceName string

@description('Specifies the desired state of the managed identity sql control settings. Determine to grant sql control to managed identity.')
@allowed([
  'Enabled'
  'Disabled'
])
param desiredStateGrantSqlControlToManagedIdentity string = 'Enabled'

// ================================================= Existing Resources ========================================
@description('Existing Synapse Workspace')
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: synapseWorkSpaceName
}

// ================================================= Resources =================================================
resource managedidsqlctl 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-06-01' = {
  name: 'default'
  parent: synapseWorkspace
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: desiredStateGrantSqlControlToManagedIdentity
    }
  }
}
