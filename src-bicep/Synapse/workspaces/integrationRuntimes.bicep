/*
.SYNOPSIS
Create a Synapse Workspace integration runtime.
.DESCRIPTION
Create a Synapse Workspace integration runtime with the given specs.
.EXAMPLE
<pre>
module synapseir 'br:contosoregistry.azurecr.io/synapse/workspaces/integrationruntimes:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 50), 'synapseir')
  params: {
    synapseWorkSpaceName: 'synapsews'
    integrationRuntimeName: 'synapseir'
    type: 'Managed'
  }
}
</pre>
<p>Creates an Synapse Analytics Workspace integration runtime.</p>
.LINKS
- [Bicep Microsoft.Synapse workspaces integration runtime](https://learn.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/integrationruntimes?pivots=deployment-language-bicep)
*/

// ================================================= Parameters =================================================
@description('Conditional. The name of the parent Synapse Workspace. Required if the template is used in a standalone deployment.')
param workspaceName string

@description('Required. The name of the Integration Runtime.')
param integrationRuntimeName string

@allowed([
  'Managed'
  'SelfHosted'
])
@description('Required. The type of Integration Runtime.')
param type string

@description('Conditional. Integration Runtime type properties. Required if type is "Managed".')
param typeProperties object = {}

resource workspace 'Microsoft.Synapse/workspaces@2021-06-01' existing = {
  name: workspaceName
}

resource integrationRuntime 'Microsoft.Synapse/workspaces/integrationRuntimes@2021-06-01' = {
  name: integrationRuntimeName
  parent: workspace
  properties: type == 'Managed'
    ? {
        type: type
        managedVirtualNetwork: {
          referenceName: 'default'
          type: 'ManagedVirtualNetworkReference'
        }
        typeProperties: typeProperties
      }
    : {
        type: type
      }
}

@description('The name of the Resource Group the Integration Runtime was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the Integration Runtime.')
output integrationRuntimeName string = integrationRuntime.name

@description('The resource ID of the Integration Runtime.')
output integrationRuntimeResourceId string = integrationRuntime.id
