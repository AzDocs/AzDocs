/*
.SYNOPSIS
Creating a Kusto cluster.
.DESCRIPTION
This module is used for creating a Kusto cluster.
.EXAMPLE
<pre>
module kustoCluster 'br/azdocs:kusto/clusters:latest' = {
  name: '${take(deployment().name, 60)}-dec'
  params:{
    clusterName: 'dec-example-dev'
    sku: {
      name: 'Dev(No SLA)_Standard_E2a_v4'
      capacity: 1
    }
  } 
}
</pre>
<p> This example creates a Kusto cluster with the name specified in the 'clusterName' parameter and uses the 'Dev(No SLA)_Standard_E2a_v4' SKU with a capacity of 1.</p>
.EXAMPLE
<pre>
module kustoCluster 'br/azdocs:kusto/clusters:latest' = {
  name: '${take(deployment().name, 60)}-dec'
  params:{
    clusterName: 'dec-example-prd'
    sku: {
      name:  'Standard_E2ads_v5'
      capacity: 2
    }
  } 
}  
</pre>
<p> This example creates a Kusto cluster with the name specified in the 'clusterName' parameter and uses the 'Standard_E2ads_v5' SKU with a capacity of 2.</p>
.LINKS
- [Bicep Microsoft.Kusto clusters/principalAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters/principalassignments?pivots=deployment-language-bicep)
*/

@description('The location of this logic app to reside in. This defaults to the resourcegroup location.')
param location string = resourceGroup().location

@description('Name of the kusto cluster')
param clusterName string

@description('Sku name to use (vm size)')
type skuNames =
  | 'Dev(No SLA)_Standard_D11_v2'
  | 'Dev(No SLA)_Standard_E2a_v4'
  | 'Standard_D11_v2'
  | 'Standard_D12_v2'
  | 'Standard_D13_v2'
  | 'Standard_D14_v2'
  | 'Standard_D16d_v5'
  | 'Standard_D32d_v4'
  | 'Standard_D32d_v5'
  | 'Standard_DS13_v2+1TB_PS'
  | 'Standard_DS13_v2+2TB_PS'
  | 'Standard_DS14_v2+3TB_PS'
  | 'Standard_DS14_v2+4TB_PS'
  | 'Standard_E16ads_v5'
  | 'Standard_E16as_v4+3TB_PS'
  | 'Standard_E16as_v4+4TB_PS'
  | 'Standard_E16as_v5+3TB_PS'
  | 'Standard_E16as_v5+4TB_PS'
  | 'Standard_E16a_v4'
  | 'Standard_E16d_v4'
  | 'Standard_E16d_v5'
  | 'Standard_E16s_v4+3TB_PS'
  | 'Standard_E16s_v4+4TB_PS'
  | 'Standard_E16s_v5+3TB_PS'
  | 'Standard_E16s_v5+4TB_PS'
  | 'Standard_E2ads_v5'
  | 'Standard_E2a_v4'
  | 'Standard_E2d_v4'
  | 'Standard_E2d_v5'
  | 'Standard_E4ads_v5'
  | 'Standard_E4a_v4'
  | 'Standard_E4d_v4'
  | 'Standard_E4d_v5'
  | 'Standard_E64i_v3'
  | 'Standard_E80ids_v4'
  | 'Standard_E8ads_v5'
  | 'Standard_E8as_v4+1TB_PS'
  | 'Standard_E8as_v4+2TB_PS'
  | 'Standard_E8as_v5+1TB_PS'
  | 'Standard_E8as_v5+2TB_PS'
  | 'Standard_E8a_v4'
  | 'Standard_E8d_v4'
  | 'Standard_E8d_v5'
  | 'Standard_E8s_v4+1TB_PS'
  | 'Standard_E8s_v4+2TB_PS'
  | 'Standard_E8s_v5+1TB_PS'
  | 'Standard_E8s_v5+2TB_PS'
  | 'Standard_EC16ads_v5'
  | 'Standard_EC16as_v5+3TB_PS'
  | 'Standard_EC16as_v5+4TB_PS'
  | 'Standard_EC8ads_v5'
  | 'Standard_EC8as_v5+1TB_PS'
  | 'Standard_EC8as_v5+2TB_PS'
  | 'Standard_L16as_v3'
  | 'Standard_L16s'
  | 'Standard_L16s_v2'
  | 'Standard_L16s_v3'
  | 'Standard_L32as_v3'
  | 'Standard_L32s_v3'
  | 'Standard_L4s'
  | 'Standard_L8as_v3'
  | 'Standard_L8s'
  | 'Standard_L8s_v2'
  | 'Standard_L8s_v3'

@description('Vm type and number of vm\'s to use')
type AzureSku = {
  name: skuNames
  capacity: int
}

@description('Vm type and number of vm\'s to use')
param sku AzureSku = {
  name: 'Dev(No SLA)_Standard_E2a_v4'
  capacity: 1
}

@export()
@description('An AVM-aligned type for a managed identity configuration. To be used if both a system-assigned & user-assigned identities are supported by the resource provider.')
type managedIdentityAllType = {
  @description('Optional. Enables system assigned managed identity on the resource.')
  systemAssigned: bool?

  @description('Optional. The resource ID(s) to assign to the resource. Required if a user assigned identity is used for encryption.')
  userAssignedResourceIds: string[]?
}

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentityAllType = { systemAssigned: true }

@description('Enable/disable zone redundancy.')
param enableZoneRedundant bool = true

// Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }
var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
)

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

resource cluster 'Microsoft.Kusto/clusters@2024-04-13' = {
  location: location
  name: clusterName
  sku: {
    name: sku.name
    tier: startsWith(sku.name, 'Dev(No SLA)') ? 'basic' : 'Standard'
    capacity: startsWith(sku.name, 'Dev(No SLA)_') ? 1 : sku.capacity < 2 ? 2 : sku.capacity
  }
  identity: identity
  zones: enableZoneRedundant
    ? [
        '1'
        '2'
        '3'
      ]
    : null
}

@description('The kusto cluster resource id.')
output clusterId string = cluster.id

@description('The kusto cluster resource name.')
output clusterName string = cluster.name
