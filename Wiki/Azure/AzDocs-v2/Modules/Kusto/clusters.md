# clusters

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="skuNames">skuNames</a>  | <pre>&nbsp;&nbsp;&nbsp;&#124; 'Dev(No SLA)_Standard_D11_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Dev(No SLA)_Standard_E2a_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D11_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D12_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D13_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D14_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D16d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D32d_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_D32d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_DS13_v2+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_DS13_v2+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_DS14_v2+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_DS14_v2+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16as_v4+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16as_v4+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16as_v5+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16as_v5+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16a_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16d_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16s_v4+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16s_v4+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16s_v5+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E16s_v5+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E2ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E2a_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E2d_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E2d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E4ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E4a_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E4d_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E4d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E64i_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E80ids_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8as_v4+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8as_v4+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8as_v5+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8as_v5+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8a_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8d_v4'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8d_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8s_v4+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8s_v4+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8s_v5+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_E8s_v5+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC16ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC16as_v5+3TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC16as_v5+4TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC8ads_v5'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC8as_v5+1TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_EC8as_v5+2TB_PS'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L16as_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L16s'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L16s_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L16s_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L32as_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L32s_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L4s'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L8as_v3'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L8s'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L8s_v2'<br>&nbsp;&nbsp;&nbsp;&#124; 'Standard_L8s_v3'<br></pre> |  | Sku name to use (vm size) | 
| <a id="AzureSku">AzureSku</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;name: skuNames<br>&nbsp;&nbsp;&nbsp;capacity: int<br>}<br></pre> |  | Vm type and number of vm\'s to use | 
| <a id="managedIdentityAllType">managedIdentityAllType</a>  | <pre>{<br>&nbsp;&nbsp;&nbsp;@description('Optional. Enables system assigned managed identity on the resource.')<br>&nbsp;&nbsp;&nbsp;systemAssigned: bool?<br><br>&nbsp;&nbsp;&nbsp;@description('Optional. The resource ID(s) to assign to the resource. Required if a user assigned identity is used for encryption.')<br>&nbsp;&nbsp;&nbsp;userAssignedResourceIds: string[]?<br>}<br></pre> |  | An AVM-aligned type for a managed identity configuration. To be used if both a system-assigned & user-assigned identities are supported by the resource provider. | 

## Synopsis
Creating a Kusto cluster.

## Description
This module is used for creating a Kusto cluster.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | The location of this logic app to reside in. This defaults to the resourcegroup location. |
| clusterName | string | <input type="checkbox" checked> | None | <pre></pre> | Name of the kusto cluster |
| sku | [AzureSku](#AzureSku) | <input type="checkbox"> | None | <pre>{<br>  name: 'Dev(No SLA)_Standard_E2a_v4'<br>  capacity: 1<br>}</pre> | Vm type and number of vm\'s to use |
| managedIdentities | [managedIdentityAllType](#managedIdentityAllType) | <input type="checkbox"> | None | <pre>{ systemAssigned: true }</pre> | Optional. The managed identity definition for this resource. |
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
