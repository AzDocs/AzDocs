# elasticpools

Target Scope: resourceGroup

## User Defined Types
| Name | Type | Discriminator | Description
| -- |  -- | -- | -- |
| <a id="elasticPoolLicenseType">elasticPoolLicenseType</a>  | <pre>'LicenseIncluded' &#124; 'BasePrice'</pre> |  | The Elastic Pool license type. For options, please refer to [elasticPoolLicenseType]. | 
| <a id="elasticPoolAvailabilityZoneType">elasticPoolAvailabilityZoneType</a>  | <pre>'1' &#124; '2' &#124; '3' &#124; 'NoPreference'</pre> |  | The elastic pool availability zone. For options, please refer to [elasticPoolAvailabilityZone]. | 
| <a id="elasticPoolPreferredEnclaveType">elasticPoolPreferredEnclaveType</a>  | <pre>'Default' &#124; 'VBS'</pre> |  | The preferred enclave type of the Elastic Pool. For options, please refer to [elasticPoolPreferredEnclaveType]. | 
| <a id="elasticPoolSkuName">elasticPoolSkuName</a>  | <pre>'BC_Gen4' &#124; 'GP_Gen4' &#124; 'HS_Gen5' &#124; 'BC_Gen5' &#124; 'GP_Gen5'</pre> |  | The sku name of the Elastic Pool. For options, please refer to [elasticPoolSkuName]. | 
| <a id="elasticPoolSkuFamily">elasticPoolSkuFamily</a>  | <pre>'Gen5' &#124; 'Gen4'</pre> |  | The sku family of the Elastic Pool. For options, please refer to [elasticPoolSkuFamily]. | 
| <a id="elasticPoolSkuCapacity">elasticPoolSkuCapacity</a>  | <pre>int</pre> |  | The sku capacity of the Elastic Pool. For options, please refer to [elasticPoolSkuCapacity]. | 
| <a id="elasticPoolSkuTier">elasticPoolSkuTier</a>  | <pre>'GeneralPurpose' &#124; 'BusinessCritical' &#124; 'Hyperscale'</pre> |  | The sku tier of the Elastic Pool. For options, please refer to [elasticPoolSkuTier]. | 
| <a id="elasticPoolSkuSize">elasticPoolSkuSize</a>  | <pre>'Basic' &#124; 'Standard' &#124; 'Premium' &#124; 'GeneralPurpose' &#124; 'BusinessCritical' &#124; 'Hyperscale'</pre> |  | The Elastic Pool sku size. For options, please refer to [elasticPoolSkuSize]. | 
| <a id="elasticPoolSku">elasticPoolSku</a>  | <pre>{</pre> |  | The Elastic Pool sku type. For options, please refer to [elasticPoolSku]. | 

## Synopsis
Creating an elastic pool

## Description
Creating an elastic pool with the given specs.

## Parameters
| Name | Type | Required | Validation | Default value | Description |
| -- |  -- | -- | -- | -- | -- |
| location | string | <input type="checkbox"> | None | <pre>resourceGroup().location</pre> | Specifies the Azure location where the resource should be created. Defaults to the resourcegroup location. |
| sqlServerName | string | <input type="checkbox" checked> | Length between 1-63 | <pre></pre> | The resourcename of the SQL Server to use (should be pre-existing). |
| elasticPoolName | string | <input type="checkbox" checked> | None | <pre></pre> | The Elastic Pool name. |
| databaseCapacityMin | int | <input type="checkbox"> | None | <pre>0</pre> | The Elastic Pool database capacity min. |
| databaseCapacityMax | int | <input type="checkbox"> | None | <pre>2</pre> | The Elastic Pool database capacity max. |
| elasticPoolLicense | elasticPoolLicenseType | <input type="checkbox"> | None | <pre>'LicenseIncluded'</pre> | The license type for the Elastic Pool. |
| elasticPoolZoneRedundant | bool | <input type="checkbox"> | None | <pre>false</pre> | Specifies whether the Elastic Pool is zone redundant. |
| elasticPoolAvailabilityZone | elasticPoolAvailabilityZoneType | <input type="checkbox"> | None | <pre>'NoPreference'</pre> | The availability zone for the Elastic Pool. |
| elasticPoolHighAvailabilityMode | int | <input type="checkbox"> | Value between 0-3 | <pre>1</pre> | The high availability replica count for the Elastic Pool. |
| elasticPoolMaxSizeBytes | int | <input type="checkbox"> | None | <pre>268435456000 // 250 GB</pre> | The maximum size in bytes for the Elastic Pool. |
| elasticPoolPreferredEnclave | elasticPoolPreferredEnclaveType | <input type="checkbox"> | None | <pre>'Default'</pre> | The preferred enclave type for the Elastic Pool. |
| sku | elasticPoolSku | <input type="checkbox"> | None | <pre>{<br>  name: 'GP_Gen5'<br>  tier: 'GeneralPurpose'<br>  family: 'Gen5'<br>  capacity: 2<br>}</pre> | The SKU object to use for this Elastic Pool. Defaults to a standard pool. <br>Example<br>param sku object = {<br>&nbsp;&nbsp;&nbsp;name: 'PremiumPool'<br>&nbsp;&nbsp;&nbsp;tier: 'Premium'<br>} |

## Outputs
| Name | Type | Description |
| -- |  -- | -- |
| elasticPoolId | string | The resource id of the Elastic Pool. |
| elasticPoolName | string | The resource name of the Elastic Pool. |

## Examples
<pre>
module sql 'br:contosoregistry.azurecr.io/sql/servers/elasticpools.bicep:latest' = {
  name: format('{0}-{1}', take('${deployment().name}', 61), 'ep')
  params: {
    sku: {
      name: 'GP_Gen5'
      tier: 'GeneralPurpose'
      capacity: 2
      family: 'Gen5'
    }
    sqlServerName: sqlserver.outputs.sqlServerName
    location: location
    elasticPoolName: 'elasticpoolname'
    databaseCapacityMin: 0
    databaseCapacityMax: 10
    elasticPoolPreferredEnclave: 'Default'
    elasticPoolLicense: 'LicenseIncluded'
    elasticPoolZoneRedundant: false
    elasticPoolAvailabilityZone: 'NoPreference'
    elasticPoolHighAvailabilityMode: 1
    elasticPoolMaxSizeBytes: 268435456000 // 250 GB
  }
}
</pre>
<p>Creates an elastic pool with the name elasticpoolname</p>

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/elasticpools?pivots=deployment-language-bicep)
