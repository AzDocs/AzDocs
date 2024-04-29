# elasticpools

Target Scope: resourceGroup

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
| sku | object | <input type="checkbox"> | None | <pre>{<br>  name: 'StandardPool'<br>  tier: 'Standard'<br>  capacity: 50<br>}</pre> | The SKU object to use for this Elastic Pool. Defaults to a standard pool. <br>Example<br>param sku object = {<br>&nbsp;&nbsp;&nbsp;name: 'PremiumPool'<br>&nbsp;&nbsp;&nbsp;tier: 'Premium'<br>} |

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
      name: 'StandardPool'
      tier: 'Standard'
      capacity: 50
    }
    sqlServerName: sqlserver.outputs.sqlServerName
    location: location
    elasticPoolName: 'elasticpoolname'
    databaseCapacityMin: 0
    databaseCapacityMax: 10
  }
}
</pre>
<p>Creates an elastic pool with the name elasticpoolname</p>

## Links
- [Bicep Microsoft.SQL servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/elasticpools?pivots=deployment-language-bicep)
