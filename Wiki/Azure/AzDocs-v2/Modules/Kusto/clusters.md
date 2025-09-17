# clusters

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="skuNames">skuNames</a>  | <pre></pre> |  | Sku name to use (vm size) | 
| <a id="AzureSku">AzureSku</a>  | <pre>{</pre> |  | Vm type and number of vm\'s to use | 
| <a id="managedIdentityAllType">managedIdentityAllType</a>  | <pre>{</pre> |  | An AVM-aligned type for a managed identity configuration. To be used if both a system-assigned & user-assigned identities are supported by the resource provider. | 

## Synopsis
Creating a Kusto cluster.

## Description
This module is used for creating a Kusto cluster.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of this logic app to reside in. This defaults to the resourcegroup location. |
| clusterName | string | <input type="checkbox" checked> | None | <pre></pre> | Name of the kusto cluster |
| sku | AzureSku | <input type="checkbox"> | None | <pre>{<br>  name: 'Dev(No SLA)_Standard_E2a_v4'<br>  capacity: 1<br>}</pre> | Vm type and number of vm\'s to use |
| managedIdentities | managedIdentityAllType | <input type="checkbox"> | None | <pre>{ systemAssigned: true }</pre> | Optional. The managed identity definition for this resource. |
| enableZoneRedundant | bool | <input type="checkbox"> | None | <pre>true</pre> | Enable/disable zone redundancy. |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| clusterId | string | The kusto cluster resource id. |
| clusterName | string | The kusto cluster resource name. |

## Examples
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

## Links
- [Bicep Microsoft.Kusto clusters/principalAssignments](https://learn.microsoft.com/en-us/azure/templates/microsoft.kusto/clusters/principalassignments?pivots=deployment-language-bicep)
